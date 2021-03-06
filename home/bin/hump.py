#!/usr/bin/python3
import argparse
import sys
import os
import itertools
import re

################
# CONFIG CLASS #
################

class Config:
	def __init__(self):
		# get terminal width. using tput instead of stty because it has fewer issues.
		self.TERM_COLS = int(os.popen('tput cols', 'r').read())

		# Color code to reset to default colors. You probably don't want to change this.
		self.RESET_COLOR = '\033[m'

		# Color codes for data columns. This list will be repeatedly iterated in order for each column.
		# self.COL_COLORS = ['\033[38;5;39m', '\033[38;5;240m']
		self.COL_COLORS = [ '\033[96m', '\033[94m' ]

		# Color code for offset columns.
		# self.OFF_COLOR = RESET_COLOR
		# self.OFF_COLOR = '\033[38;5;37m'
		self.OFF_COLOR = '\033[32m'

		# Color code and display character for the frame between columns
		# self.FRAME_COLOR = '\033[38;5;24m'
		self.FRAME_COLOR = '\033[36m'
		self.FRAME_CHAR = '|'
		self.FRAME = self.FRAME_COLOR + self.FRAME_CHAR

		# default columns
		self.DEFAULT_COLS = [ DecimalOffsetColumn, HexDataColumn, AsciiDataColumn ]
		
		# padding char for the last line
		self.PAD_CHAR = ' '

		# Default value used to determine offset column width (see -W / --wval)
		self.OFF_MAX = (1 << 16) - 1

		# Whether or not to display summary
		self.SUMMARY = False
		
		# color themes!
		self.DEFAULT_THEME = 'vexing'
		self.THEMES = {
			'rainbow': ColorTheme('\033[m', [ '\033[38;5;196m', '\033[38;5;202m', '\033[38;5;226m', '\033[38;5;83m', '\033[38;5;33m', '\033[38;5;20m', '\033[38;5;91m' ], '\033[38;5;226m', '\033[38;5;83m', '||'),
			'cyan': ColorTheme('\033[m', ['\033[38;5;39m', '\033[38;5;240m'], '\033[38;5;37m', '\033[36m', '|'),
			'3bit': ColorTheme('\033[m', [ '\033[38;5;39m', '\033[38;5;69m' ], '\033[32m', '\033[36m', '|'),
			'vexing': ColorTheme('\033[m', [ '\033[96m', '\033[94m' ], '\033[38;5;44m', '\033[38;5;25m', '|')
		}
		self.theme = self.THEMES[self.DEFAULT_THEME]

class ColorTheme:
	def __init__(self, reset_color, col_colors, off_color, frame_color, frame_char):
		self.RESET_COLOR = reset_color
		self.COL_COLORS = col_colors
		self.OFF_COLOR = off_color
		self.FRAME_COLOR = frame_color
		self.FRAME_CHAR = frame_char
		self.FRAME = self.FRAME_COLOR + self.FRAME_CHAR

##################
# COLUMN CLASSES #
##################

class Column:
	''' Superclass for all columns '''
	def __init__(self, config):
		self.config = config
		self.color = True

class OffsetColumn(Column):
	''' Superclass for all offset columns '''
	def __init__(self, config):
		super().__init__(config)
		self.static = True

	def format(self, line):
		return (self.config.theme.OFF_COLOR if self.color else '') + (self.fmt % line.offset)

class DataColumn(Column):
	''' Superclass for all data columns '''
	def __init__(self, config):
		super().__init__(config)
		self.static = False

	def col_width(self):
		''' Attempts to determine the max width of a column using the max value (255), used for padding '''
		return len((self.fmt % 255)) 

	def format(self, line):
		''' Formats the line into a printable string using the subclass' format '''
		if self.color:
			out = ''.join([self.config.theme.COL_COLORS[i%len(self.config.theme.COL_COLORS)] + (self.fmt % byte) for (i, byte) in enumerate(line)])
		else:
			out = self.config.theme.RESET_COLOR + ''.join([(self.fmt % byte) for (i, byte) in enumerate(line)])

		# if this is a partial (i.e. last) line, pad it with the pad character
		out += self.col_width() * (line.size - len(line)) * self.config.PAD_CHAR
		return out

class OctalDataColumn(DataColumn):
	''' Format class for octal data columns '''
	def __init__(self, config):
		super().__init__(config)
		self.fmt = '%03o'

class OctalOffsetColumn(OffsetColumn):
	''' Format class for octal offset columns '''
	def __init__(self, config):
		super().__init__(config)
		self.fmt = '%0' + str(len('%o' % config.OFF_MAX)) + 'o'

class DecimalDataColumn(DataColumn):
	''' Format class for decimal data columns '''
	def __init__(self, config):
		super().__init__(config)
		self.fmt = '%3d'

class DecimalOffsetColumn(OffsetColumn):
	''' Format class for decimal offset columns '''
	def __init__(self, config):
		super().__init__(config)
		self.fmt = '%' + str(len('%d' % config.OFF_MAX)) + 'd'

class HexDataColumn(DataColumn):
	''' Format class for hexidecimal data columns '''
	def __init__(self, config):
		super().__init__(config)
		self.fmt = '%02x'

class HexOffsetColumn(OffsetColumn):
	''' Format class for hexidecimal offset columns '''
	def __init__(self, config):
		super().__init__(config)
		self.fmt = '%0' + str(len('%x' % config.OFF_MAX)) + 'x'

class AsciiDataColumn(DataColumn):
	''' Format class for ASCII data columns '''
	def __init__(self, config):
		super().__init__(config)
		self.fmt = '%c'
		self.color = False

	def col_width(self):
		''' ASCII data columns are always width 1, no need to calculate '''
		return 1

	# overrides format method to filter out non-printable characters
	def format(self, line):
		return super().format(Line(line.offset, line.size, [b if b >= 32 and b <= 126 else 46 for b in line]))

#################
# INPUT CLASSES #
#################

# represents data for one row
class Line(list):
	''' This class represents the data needed by column classes for a single line of output '''
	def __init__(self, offset, size, *args, **kwargs):
		self.size = size
		self.offset = offset
		super().__init__(*args, **kwargs)

	def next_offset(self):
		''' Returns the next offset '''
		return self.offset + self.size

	def __repr__(self):
		return '[%d: \'%s\']' % (self.size, ''.join([chr(b) if b >= 32 and b <= 126 else '.' for b in self]))

	def __str__(self):
		return self.__repr__()

def file_reader(paths, line_size):
	''' A generator for reading files into Line objects '''
	# if there weren't any paths in the arguments, use stdin
	if not paths:
		paths = ['-']

	# create initial buffer
	line = Line(0, line_size)

	# iterate over each file
	for path in paths:
		# open the file
		f = sys.stdin.buffer if path == '-' else open(path, 'rb')

		# iterate over each block returned by read()
		for block in f:
			for byte in block:
				if len(line) < line.size:
					# if the line isn't full yet, append this byte
					line.append(byte)
				else:
					# otherwise yield the line and create a new one
					yield line
					line = Line(line.next_offset(), line.size, [byte])

		# close the file
		f.close()

	# yield whatever is left
	if line:
		yield line

#################
# INITIAL SETUP #
#################

def arg_parser(config):
	''' Builds an argparse ArgumentParser '''
	parser = argparse.ArgumentParser(description='Dumps binary data using the specified columns. ' + \
		'If no columns are specified, a default format will be used.')

	# data column args
	data_col_group = parser.add_argument_group('Data Columns', 'Specify data columns to be displayed.')
	data_col_group.add_argument('-o', action='append_const', dest='col_classes', const=OctalDataColumn,
		help='Octal data column. May be specified more than once.')
	data_col_group.add_argument('-d', action='append_const', dest='col_classes', const=DecimalDataColumn,
		help='Decimal data column. May be specified more than once.')
	data_col_group.add_argument('-x', action='append_const', dest='col_classes', const=HexDataColumn,
		help='Hex data column. May be specified more than once.')
	data_col_group.add_argument('-a', action='append_const', dest='col_classes', const=AsciiDataColumn,
		help='ASCII data column. May be specified more than once.')

	# offset column args
	off_col_group = parser.add_argument_group('Offset Columns', 'Specify offset columns to be displayed.')
	off_col_group.add_argument('-O', action='append_const', dest='col_classes', const=OctalOffsetColumn,
		help='Octal offset column. May be specified more than once.')
	off_col_group.add_argument('-D', action='append_const', dest='col_classes', const=DecimalOffsetColumn,
		help='Decimal offset column. May be specified more than once.')
	off_col_group.add_argument('-X', action='append_const', dest='col_classes', const=HexOffsetColumn,
		help='Hex offset column. May be specified more than once.')

	# other args
	parser.add_argument('-W', '--wval', help='Set value used to determine offset column width. ' + \
		'The next power of 2 after the expected input length is generally a safe value.') 
	parser.add_argument('files', metavar='FILE', nargs='*',
		help='Specifies a file or files to read. If FILE is -, read from standard input. ' + \
		'If no FILE is specified, read only from standard input.')
	parser.add_argument('-s', dest='summary', action='count',  help='Display a brief summary at the end of output.')
	parser.add_argument('-t', dest='theme', help='Specify color theme. Options: ' + ', '.join(config.THEMES.keys()))


	return parser

def strip_colors(string):
	''' Strips ASCII colors out of a string '''
	return re.sub(r'\033\[(\d\d?;?)*?m', '', string)

def render_line(config, cols, line):
	''' Renders a Line into a printable string using the provided configuration and column classes '''
	return config.theme.FRAME.join([col.format(line) for col in cols])

def setup():
	# setup
	config = Config()
	parser = arg_parser(config)
	args = parser.parse_args()

	# decide whether or not to print a summary
	config.SUMMARY = args.summary

	# apply a theme if one was chosen
	if args.theme:
		config.theme = config.THEMES[args.theme]

	# if the offset width value option was specified, apply it
	if args.wval:
		config.OFF_MAX = int(args.wval)

	# create column objects
	col_classes = args.col_classes or config.DEFAULT_COLS
	cols = [col_class(config) for col_class in col_classes]

	# figure out how many data columns we can have
	if list(filter(lambda col: not col.static, cols)):
		# if we have non-static-width (e.g. data) columns, figure out how many bytes we can display per line
		for data_cols in itertools.count():
			# render the line with maximum values so we can get the width
			max_line = Line(0, data_cols, [ 255 ] * data_cols)
			width = len(strip_colors(render_line(config, cols, max_line)))

			if width > config.TERM_COLS:
				break
		data_cols -= 1
	else:
		# if we only have static-width (e.g. offset) columns, set the data column count to 1
		data_cols = 1

	# create input reader
	reader = file_reader(args.files, data_cols) if args.files else file_reader(None, data_cols)

	return (config, cols, reader)

########
# MAIN #
########

def main():
	# do initial setup
	(config, cols, reader) = setup()

	# iterate over lines from reader
	byte_count = 0
	for line in reader:
		# print rendered line
		print(render_line(config, cols, line))
		byte_count += len(line)

	# write summary
	if config.SUMMARY:
		print('Displayed %d bytes per line, %d bytes total' % (data_cols, byte_count))		
 
if __name__ == '__main__':
	main()
