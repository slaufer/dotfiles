/*
 *  FMDisplayItem.c
 *  FountainMusic
 *
 *  Copyright 2005, 2006 Brian Moore
 *
 *  This file is part of Fountain Music.
 *
 *  Fountain Music is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  Fountain Music is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Fountain Music; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include "FMDisplayItem.h"
#import <OpenGL/gl.h>

#ifndef MAX
#define MAX(a, b) ((a)>(b)?(a):(b))
#endif

#ifndef MIN
#define MIN(a, b) ((a)<(b)?(a):(b))
#endif

#define kFMMaxItemHeight 768
#define kFMMaxItemWidth 1024
#define kFMDisplayItemStringMaxLength 256

struct FMDisplayItem
{
	int id;

	float x;
	float y;
	
	FMDisplayItemAlignmentFlags alignment;
	
	UniChar text[kFMDisplayItemStringMaxLength+1];
	int textLength;
	
	float timeToDie;
	float fadeTime;
	
	int bitmapWidth;
	int bitmapHeight;
	UInt8 *bitmapData;
	
	Float32 textSize;
	ATSUStyle textStyle;
	ATSUTextLayout textLayout;
	
	float textOffsetX, textOffsetY;

	// graphics
	Boolean graphicsSetUp;
	GLuint texName;
	Boolean textureDirty;
	CGContextRef bitmapCtx;
	CGColorSpaceRef colorSpace;
	
};

float FadeOutValueForTime(float timeRemaining, float fadeDuration);
int u_strncmp(UniChar *s1, UniChar *s2, int strLen);

// ATSUI convenience methods
void FMATSUSetLayoutCGContext(ATSUTextLayout layout, CGContextRef ctx);
void FMATSUSetStyleColor(ATSUStyle style, float r, float g, float b, float a);
void FMATSUSetStyleTextSize(ATSUStyle style, Float32 textSize);
//ATSUFontID FMSpecificFontID();

// private API
int FMDisplayItemGetBitmapWidth(FMDisplayItemRef item);
int FMDisplayItemGetBitmapHeight(FMDisplayItemRef item);
void FMDisplayItemSetBitmapSize(FMDisplayItemRef item, int width, int height);
void FMDisplayItemRenderText(FMDisplayItemRef item);

// item creation API
FMDisplayItemRef FMDisplayItemCreate()
{
	static int nextID = 0;
	FMDisplayItemRef newItem = calloc(1, sizeof(struct FMDisplayItem));
	
	newItem->id = nextID++;
	
	newItem->x = 0.0;
	newItem->y = 0.0;
	 
	newItem->alignment = kFMDisplayItemLeft | kFMDisplayItemBottom;
	
	newItem->text[0] = 0;
	newItem->textLength = 0;
	
	newItem->timeToDie = 0.0;
	newItem->fadeTime = 0.0;
	
	newItem->bitmapData = NULL;
	newItem->texName = 0;
	
	newItem->graphicsSetUp = FALSE;
	newItem->colorSpace = NULL;
	newItem->textureDirty = TRUE;
	
	// setup style
	newItem->textSize = 11.0; // default
	ATSUCreateStyle(&newItem->textStyle);
	
	ATSUAttributeTag styleAttrTags[] = {kATSUSizeTag, kATSURGBAlphaColorTag, kATSUQDBoldfaceTag};
	ByteCount styleAttrSizes[] = {sizeof(Fixed), sizeof(ATSURGBAlphaColor), sizeof(Boolean)};
	
	ATSURGBAlphaColor whiteColor; 
	whiteColor.red = 1.0;
	whiteColor.green = 1.0;
	whiteColor.blue = 1.0;
	whiteColor.alpha = 1.0;
	
	Boolean trueBoolean = TRUE;
	//Boolean falseBoolean = FALSE;
	/*static boolean_t specificFontSet = FALSE;
	static ATSUFontID specificFont;
	
	if (specificFontSet == FALSE) 
	{
		specificFont = FMSpecificFontID();
		specificFontSet = TRUE;
	}*/
	
	Fixed textSizeTagVal = Long2Fix(floor(newItem->textSize));
	ATSUAttributeValuePtr styleAttrValues[] = {&textSizeTagVal, &whiteColor, &trueBoolean};
	
	ATSUSetAttributes(newItem->textStyle, 3, styleAttrTags, styleAttrSizes, styleAttrValues);
	
	newItem->textLayout = NULL;
	FMDisplayItemSetStringValueCFString(newItem, CFSTR("")); // will setup the text layout
	
	return newItem;
}

void FMDisplayItemDelete(FMDisplayItemRef item)
{
	if (item->graphicsSetUp) FMDisplayItemCleanupGraphics(item);
	free(item->bitmapData);
	free(item);
}

void FMDisplayItemSetPosition(FMDisplayItemRef item, float newX, float newY)
{
	item->x = newX;
	item->y = newY;
}

float FMDisplayItemGetFadeTime(FMDisplayItemRef item)
{
	return item->fadeTime;
}
void FMDisplayItemSetFadeTime(FMDisplayItemRef item, float newFadeTime)
{
	item->fadeTime = newFadeTime;
}

float FMDisplayItemGetTimeToDie(FMDisplayItemRef item)
{
	return item->timeToDie;
}
void FMDisplayItemSetTimeToDie(FMDisplayItemRef item, float newTime)
{
	item->timeToDie = newTime;
}

Float32 FMDisplayItemGetTextSize(FMDisplayItemRef item)
{
	return item->textSize;
}

void FMDisplayItemSetTextSize(FMDisplayItemRef item, Float32 inSize)
{
	float oldSize = FMDisplayItemGetTextSize(item);
	
	item->textSize = inSize;
	
	if (oldSize != FMDisplayItemGetTextSize(item))
	{
		FMATSUSetStyleTextSize(item->textStyle, item->textSize);
		item->textureDirty = TRUE;
	}
}

void FMDisplayItemStep(FMDisplayItemRef item, float deltaT)
{
	if (item->timeToDie > 0.0)
	{
		item->timeToDie -= deltaT;
		if (item->timeToDie < 0.0) item->timeToDie = 0.0;
	}
	
}

float FMDisplayItemAlpha(FMDisplayItemRef item)
{
	return FadeOutValueForTime(item->timeToDie, item->fadeTime);
}

int FMDisplayItemGetBitmapWidth(FMDisplayItemRef item)
{
	return item->bitmapWidth;
}

int FMDisplayItemGetBitmapHeight(FMDisplayItemRef item)
{
	return item->bitmapHeight;
}

void FMDisplayItemSetBitmapSize(FMDisplayItemRef item, int width, int height)
{
	height = height > kFMMaxItemHeight ? kFMMaxItemHeight : height;
	width = width > kFMMaxItemWidth ? kFMMaxItemWidth : width;

	if (width > item->bitmapWidth || height > item->bitmapHeight)
	{
		item->bitmapHeight = height;
		item->bitmapWidth = width;
		
		if (item->bitmapData) free(item->bitmapData);
		
		item->bitmapData = calloc(item->bitmapHeight * item->bitmapWidth, 4*sizeof(UInt8));
		
		if (item->graphicsSetUp)
		{
			CGContextRelease(item->bitmapCtx);
		
			item->bitmapCtx = CGBitmapContextCreate(item->bitmapData,
													item->bitmapWidth,
													item->bitmapHeight,
													8, // bits per component
													item->bitmapWidth*4,
													item->colorSpace,
													kCGImageAlphaPremultipliedLast);
													
			FMATSUSetLayoutCGContext(item->textLayout, item->bitmapCtx);
			
			item->textureDirty = TRUE;
		}
	}
}

void FMDisplayItemSetStringValueMacRoman(FMDisplayItemRef item, const char *newText)
{
	int stringLength;
	
	stringLength = MIN(kFMDisplayItemStringMaxLength, strlen(newText));
	
	// convert from MacRoman to UTF-16
	CFStringRef uniString = CFStringCreateWithBytes(NULL, (UInt8 *)newText, stringLength, kCFStringEncodingMacRoman, TRUE);
	
	FMDisplayItemSetStringValueCFString(item, uniString);
		
	CFRelease(uniString);
}

void FMDisplayItemSetStringValueCFString(FMDisplayItemRef item, CFStringRef str)
{	
	CFIndex usedLen;
	UniChar oldStr[kFMDisplayItemStringMaxLength];

	// save old string for comparison later
	memcpy(oldStr, item->text, sizeof(UniChar)*kFMDisplayItemStringMaxLength);
	
	// zero the text buffer
	memset(item->text, 0, sizeof(UniChar)*kFMDisplayItemStringMaxLength);
	
	// copy UTF-16 representation of string into text for ATSU
	CFStringGetBytes(str, CFRangeMake(0, CFStringGetLength(str)), 
					 kCFStringEncodingUnicode, '?', TRUE,
					 (UInt8 *)item->text, sizeof(UniChar)*kFMDisplayItemStringMaxLength, &usedLen);
	
	item->textLength = usedLen/sizeof(UniChar);
	
	
	// if string is different
	if (u_strncmp(oldStr, item->text, kFMDisplayItemStringMaxLength) != 0)
	{
		if (item->textLayout)
		{
			ATSUTextDeleted(item->textLayout,
							kATSUFromTextBeginning,
							kATSUToTextEnd);
			
							
			ATSUTextInserted(item->textLayout,
							 kATSUFromTextBeginning,
							 item->textLength);
		}
		else
		{
			UniCharCount runLengths[] = { kATSUToTextEnd };
			
			ATSUCreateTextLayoutWithTextPtr(item->text,
											kATSUFromTextBeginning,
											kATSUToTextEnd,
											item->textLength,
											1, runLengths,
											&(item->textStyle),
											&(item->textLayout));
											
			// allows ATSU to use glyphs from other fonts
			ATSUSetTransientFontMatching(item->textLayout, TRUE);
											
			// set tabs
			ATSUTab tabs[1];
			
			tabs[0].tabPosition = Long2Fix(50);
			tabs[0].tabType = kATSULeftTab;
			
			ATSUSetTabArray(item->textLayout, tabs, 1);
		}
		
		// texture needs to be updated
		item->textureDirty = TRUE;
	}
}

void FMDisplayItemSetTextAlignment(FMDisplayItemRef item, FMDisplayItemAlignmentFlags flags)
{
	item->alignment = flags;
	
	item->textureDirty = TRUE;
}

void FMDisplayItemSetTextureDirty(FMDisplayItemRef item, Boolean flag)
{
	item->textureDirty = flag;
}

void FMDisplayItemSetupGraphics(FMDisplayItemRef item)
{
	if (!item->graphicsSetUp)
	{
		item->graphicsSetUp = TRUE;
		
		glGenTextures(1, &(item->texName));
		
		item->colorSpace = CGColorSpaceCreateDeviceRGB();
		
		item->bitmapCtx = CGBitmapContextCreate(item->bitmapData,
											    item->bitmapWidth,
											    item->bitmapHeight,
											    8, // bits per component
											    item->bitmapWidth*4,
											    item->colorSpace,
											    kCGImageAlphaPremultipliedLast);
												
		FMATSUSetLayoutCGContext(item->textLayout, item->bitmapCtx);
		
		item->textureDirty = TRUE;
	}
}

void FMDisplayItemCleanupGraphics(FMDisplayItemRef item)
{
	if (item->graphicsSetUp)
	{
		item->graphicsSetUp = FALSE;
		
		glDeleteTextures(1, &(item->texName));
		
		CGContextRelease(item->bitmapCtx);
		CGColorSpaceRelease(item->colorSpace);
	}
}

#define TXT_AA_PADDING (2)

void FMDisplayItemRenderText(FMDisplayItemRef item)
{
	if (item->textureDirty && item->graphicsSetUp)
	{
		Rect textRect;
		
		// obtain text metrics
		ATSUMeasureTextImage(item->textLayout,
							 kATSUFromTextBeginning,
							 kATSUToTextEnd,
							 0,
							 0,
							 &textRect);

		int offsetX, offsetY;
		int bitmapW, bitmapH;
		
		offsetX = MIN(0, textRect.left) - TXT_AA_PADDING;
		offsetY = MIN(0, -textRect.bottom) - TXT_AA_PADDING;

		bitmapW = MAX(textRect.right, 0) - MIN(textRect.left, 0) + 2*TXT_AA_PADDING;
		bitmapH = MAX(-textRect.top, 0) - MIN(-textRect.bottom, 0) + 2*TXT_AA_PADDING;
		
		item->textOffsetX = offsetX;
		item->textOffsetY = offsetY;

		if (bitmapW > 0 && bitmapH > 0)
		{
			//
			// first render into bitmap
			//
			// this may be redundant... oh well!
			FMATSUSetLayoutCGContext(item->textLayout, item->bitmapCtx);
			
			// resize bitmap and backing as needed
			FMDisplayItemSetBitmapSize(item, bitmapW, bitmapH);
			
			// zero the bitmap
			memset(item->bitmapData, 0, item->bitmapHeight * item->bitmapWidth * 4);
			
			// NO SHADOW! messes up the QD bolding of text
			//CGContextSetShadow(item->bitmapCtx, CGSizeMake(2.0, -2.0), 1.0);
		
			ATSUDrawText(item->textLayout,
						 kATSUFromTextBeginning,
						 kATSUToTextEnd,
						 Long2Fix(-offsetX),
						 Long2Fix(-offsetY));
			
			//
			// then load the bitmap into the GL texture
			//
			glEnable(GL_TEXTURE_RECTANGLE_EXT);
			glBindTexture(GL_TEXTURE_RECTANGLE_EXT, item->texName);
			
			glTexImage2D(GL_TEXTURE_RECTANGLE_EXT, 0,
						 GL_RGBA,
						 item->bitmapWidth,
						 item->bitmapHeight,
						 0,
						 GL_RGBA,
						 GL_UNSIGNED_BYTE,
						 item->bitmapData);
						 
			glDisable(GL_TEXTURE_RECTANGLE_EXT);
			
			item->textureDirty = FALSE;
		}
	}
}

void FMDisplayItemDraw(FMDisplayItemRef item)
{
	if (!item->graphicsSetUp) FMDisplayItemSetupGraphics(item);

	if (item->timeToDie > 0.0)
	{
		FMDisplayItemRenderText(item);
		
		float px, py;
					
		px = item->x + item->textOffsetX;
		py = item->y + item->textOffsetY;
		
		glEnable(GL_TEXTURE_RECTANGLE_EXT);
		glBindTexture(GL_TEXTURE_RECTANGLE_EXT, item->texName);
		
		// setup good blending for the text texture
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		glColor4f(1.0, 1.0, 1.0, FMDisplayItemAlpha(item));
					  
		glBegin(GL_QUADS);
		
			glTexCoord2f(0.0, 0.0);
			glVertex2f(px, py+item->bitmapHeight);
			
			glTexCoord2f(item->bitmapWidth, 0.0);
			glVertex2f(px+item->bitmapWidth, py+item->bitmapHeight);
			
			glTexCoord2f(item->bitmapWidth, item->bitmapHeight);
			glVertex2f(px+item->bitmapWidth, py);
			
			glTexCoord2f(0.0, item->bitmapHeight);
			glVertex2f(px, py);
		
		glEnd();
		
		glDisable(GL_TEXTURE_RECTANGLE_EXT);
	}
}

// ATSUI convenience
void FMATSUSetLayoutCGContext(ATSUTextLayout layout, CGContextRef ctx)
{
	// setup the text for CG drawing
	ATSUAttributeTag tags[] = {kATSUCGContextTag};
	ByteCount	sizes[] = {sizeof(CGContextRef)};
	ATSUAttributeValuePtr values[] = {&ctx};

	ATSUSetLayoutControls(layout, 1, tags, sizes, values);
}

void FMATSUSetStyleColor(ATSUStyle style, float r, float g, float b, float a)
{
	ATSUAttributeTag tags[] = {kATSURGBAlphaColorTag};
	ByteCount sizes[] = {sizeof(ATSURGBAlphaColor)};
	
	ATSURGBAlphaColor theColor; 
	theColor.red = r;
	theColor.green = g;
	theColor.blue = b;
	theColor.alpha = a;
	
	ATSUAttributeValuePtr values[] = {&theColor};
	
	ATSUSetAttributes(style, 1, tags, sizes, values);
}

void FMATSUSetStyleTextSize(ATSUStyle style, Float32 textSize)
{
	ATSUAttributeTag tags[] = {kATSUSizeTag};
	ByteCount sizes[] = {sizeof(Fixed)};
	
	Fixed fixedSize = FloatToFixed(textSize);
	
	ATSUAttributeValuePtr values[] = {&fixedSize};
	
	ATSUSetAttributes(style, 1, tags, sizes, values);
}
/*
ATSUFontID FMSpecificFontID()
{
	printf("finding specific font\n");
	// how to specify to use the bold typeface of the font...
	ATSUFontID *fontIDs;
	ItemCount count, nameCount;
	int i, j;
	char tempName[256];
	boolean_t lastWasTarget = FALSE;
	int tarIdx = -1;
	FontNameCode currNameCode;
	FontPlatformCode currPlatCode;
	FontScriptCode currScriptCode;
	FontLanguageCode currLangCode;
	
	ATSUFontCount(&count);
	
	fontIDs = calloc(sizeof(ATSUFontID), count);
	
	ATSUGetFontIDs(fontIDs, count, NULL);
	
	for (j=0; j<count; j++)
	{
		//printf("---------- %i: Font %i -----------\n", j, fontIDs[j]);
		
		ATSUCountFontNames(fontIDs[j], &nameCount);
		
		for (i=0; i<nameCount; i++)
		{
			memset(tempName, 0, 256);
		
			ATSUGetIndFontName(fontIDs[j],
							   i,
							   255,
							   tempName,
							   NULL,
							   &currNameCode,
							   &currPlatCode,
							   &currScriptCode,
							   &currLangCode);
			
			if (currLangCode == kFontEnglishLanguage && 
				currScriptCode == kFontRomanScript && 
				currPlatCode == kFontMacintoshPlatform &&
				(currNameCode == kFontFamilyName || currNameCode == kFontStyleName))
			{
				if (currNameCode == kFontFamilyName)
				{
					if (strcmp(tempName, "Bitstream Vera Sans") == 0)
					{
						lastWasTarget = TRUE;
					}
					else
					{
						lastWasTarget = FALSE;
					}
				}
				else if (currNameCode == kFontStyleName)
				{
					if (lastWasTarget)
					{
						if (strcmp(tempName, "Bold") == 0)
						{
							tarIdx = j;
						}
					}
				}
				
				//printf("\"%s\" (%i)\n", tempName, currNameCode);
			}
		}
	}	
	
	printf("Font is at %i\n", tarIdx);
	
	ATSUFontID returnVal;
	
	if (tarIdx != -1)
	{
		returnVal = fontIDs[tarIdx];
	}
	else returnVal = -1;
	
	free(fontIDs);
	
	printf("done finding specific font\n");
	return returnVal;
}*/

// other
float FadeOutValueForTime(float timeRemaining, float fadeDuration)
{
    float fraction;
    
    if (timeRemaining < fadeDuration) 
    {
		fraction = timeRemaining/fadeDuration;
    }
    else fraction = 1.0;
	
    return fraction;
}

int u_strncmp(UniChar *s1, UniChar *s2, int strLen)
{
	int i;
	int cmp;
	
	for (i=0; i<strLen; i++)
	{
		cmp = s2[i] - s1[i];
		if (cmp != 0) return cmp;
	}
	
	return 0;
}
