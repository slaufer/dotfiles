/*
 *  FMDisplayItem.h
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

typedef enum
{
	kFMDisplayItemLeft = 1 << 0,
	kFMDisplayItemHorizontalCenter = 1 << 1,
	kFMDisplayItemRight = 1 << 2,
	kFMDisplayItemTop = 1 << 3,
	kFMDisplayItemVerticalCenter = 1 << 4,
	kFMDisplayItemBottom = 1 << 5
} FMDisplayItemAlignmentFlags;

typedef struct FMDisplayItem *FMDisplayItemRef;

// item creation API
FMDisplayItemRef FMDisplayItemCreate();
void FMDisplayItemDelete(FMDisplayItemRef item);

void FMDisplayItemSetPosition(FMDisplayItemRef item, float newX, float newY);

float FMDisplayItemGetFadeTime(FMDisplayItemRef item);
void FMDisplayItemSetFadeTime(FMDisplayItemRef item, float newFadeTime);

float FMDisplayItemGetTimeToDie(FMDisplayItemRef item);
void FMDisplayItemSetTimeToDie(FMDisplayItemRef item, float newTime);

float FMDisplayItemGetTextSize(FMDisplayItemRef item);
void FMDisplayItemSetTextSize(FMDisplayItemRef item, float inSize);

void FMDisplayItemStep(FMDisplayItemRef item, float deltaT);
float FMDisplayItemAlpha(FMDisplayItemRef item);

void FMDisplayItemSetStringValueMacRoman(FMDisplayItemRef item, const char *newText);
void FMDisplayItemSetStringValueCFString(FMDisplayItemRef item, CFStringRef str);
void FMDisplayItemSetTextAlignment(FMDisplayItemRef item, FMDisplayItemAlignmentFlags flags);

void FMDisplayItemSetTextureDirty(FMDisplayItemRef item, Boolean flag);

void FMDisplayItemSetupGraphics(FMDisplayItemRef item);
void FMDisplayItemCleanupGraphics(FMDisplayItemRef item);

void FMDisplayItemDraw(FMDisplayItemRef item);

