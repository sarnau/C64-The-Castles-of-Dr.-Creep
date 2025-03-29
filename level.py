#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import struct
import binascii
import glob
import os

C64_COLORS = [
'BLACK','WHITE','RED','CYAN','PURPLE','GREEN','BLUE','YELLOW',
'ORANGE','BROWN','LIGHT_RED','DARK_GREY','GREY','LIGHT_GREEN','LIGHT_BLUE','LIGHT_GREY'
]

BASE_ADDR = 0x7800

def parseObjects(data,objectsOffset):
	objectIndex = 0
	while True:
		print('Object #%d: ' % (objectIndex),end='')
		objectIndex += 1
		objectID = struct.unpack('<H', data[objectsOffset:objectsOffset+2])[0]
		objectsOffset += 2
		if objectID == 0x0803:
			doorCount = data[objectsOffset]
			print('Doors #%d' % doorCount)
			objectsOffset += 1
			while doorCount > 0:
				print('X:%d,Y:%d FLAGS:%#2x ROOM #%d - ?:%d/%d/%d - TYP:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4],data[objectsOffset+5],data[objectsOffset+6],data[objectsOffset+7]))
				objectsOffset += 8
				doorCount -= 1
		elif objectID == 0x0806:
			print('Walkway')
			while data[objectsOffset] != 0:
				print('W:%d,X:%d,Y:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2]))
				objectsOffset += 3
			objectsOffset += 1
		elif objectID == 0x0809:
			print('Sliding Pole')
			while data[objectsOffset] != 0:
				print('L:%d,X:%d,Y:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2]))
				objectsOffset += 3
			objectsOffset += 1
		elif objectID == 0x080c:
			print('Ladder')
			while data[objectsOffset] != 0:
				print('H:%d,X:%d,Y:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2]))
				objectsOffset += 3
			objectsOffset += 1
		elif objectID == 0x80f:
			doorButtonCount = data[objectsOffset]
			print('Door Button #%d' % doorButtonCount)
			objectsOffset += 1
			while doorButtonCount > 0:
				print('X:%d,Y:%d %d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2]))
				objectsOffset += 3
				doorButtonCount -= 1
		elif objectID == 0x812:
			print('Lightning')
			while (data[objectsOffset] & 0x20) != 0x20:
				print('FLAGS:%#2x X:%d,Y:%d,L:%d %d,%d,%d,%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4],data[objectsOffset+5],data[objectsOffset+6],data[objectsOffset+7]))
				objectsOffset += 8
			objectsOffset += 1
		elif objectID == 0x815:
			print('Forcefield')
			while data[objectsOffset] != 0:
				print('H:%d,X:%d,Y:%d,%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3]))
				objectsOffset += 4
			objectsOffset += 1
		elif objectID == 0x818:
			print('Mummy')
			while data[objectsOffset] != 0:
				print('TYP:%d X:%d,Y:%d x:%d,y:%d %d,%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4],data[objectsOffset+5],data[objectsOffset+6]))
				objectsOffset += 7
			objectsOffset += 1
		elif objectID == 0x81b:
			print('Key')
			while data[objectsOffset] != 0:
				print('%d,IMG:%d,X:%d,Y:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3]))
				objectsOffset += 4
			objectsOffset += 1
		elif objectID == 0x81e:
			print('Door Lock')
			while data[objectsOffset] != 0:
				print('%d,%d,%d,%d,%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4]))
				objectsOffset += 5
			objectsOffset += 1
		elif objectID == 0x821:
			print('Multi-Draw')
			while data[objectsOffset] != 0:
				print('Repeat:%d IMG:%d X:%d Y:%d dX:%d dY:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4],data[objectsOffset+5]))
				objectsOffset += 6
			objectsOffset += 1
		elif objectID == 0x824:
			print('Raygun')
			while (data[objectsOffset] & 0x80) != 0x80:
				print('FLAGS:%d X:%d,Y:%d,L:%d %d x:%d,y:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4],data[objectsOffset+5],data[objectsOffset+6]))
				objectsOffset += 7
			objectsOffset += 1
		elif objectID == 0x827:
			print('Teleport')
			print('X:%d,Y:%d,C:%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2]))
			objectsOffset += 3
			while data[objectsOffset] != 0x00:
				print('%d,%d' % (data[objectsOffset],data[objectsOffset+1]))
				objectsOffset += 2
			objectsOffset += 1
		elif objectID == 0x82a:
			print('Trapdoor')
			while (data[objectsOffset] & 0x80) != 0x80:
				print('%d,%d,%d,%d,%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4]))
				objectsOffset += 5
			objectsOffset += 1
		elif objectID == 0x82d:
			print('Conveyor')
			while (data[objectsOffset] & 0x80) != 0x80:
				print('%d,%d,%d,%d,%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4]))
				objectsOffset += 5
			objectsOffset += 1
		elif objectID == 0x830:
			print('Frankenstein')
			while (data[objectsOffset] & 0x80) != 0x80:
				print('%d,%d,%d,%d,%d,%d,%d' % (data[objectsOffset],data[objectsOffset+1],data[objectsOffset+2],data[objectsOffset+3],data[objectsOffset+4],data[objectsOffset+5],data[objectsOffset+6]))
				objectsOffset += 7
			objectsOffset += 1
		elif objectID == 0x833:
			print('Text')
			while data[objectsOffset] != 0:
				print('X:%d,Y:%d COL:%s FONT:%#2x ' % (data[objectsOffset],data[objectsOffset+1],C64_COLORS[data[objectsOffset+2]],data[objectsOffset+3]),end='')
				objectsOffset += 4
				s = ''
				while (data[objectsOffset] & 0x80) == 0x00:
					s += chr(data[objectsOffset])
					objectsOffset += 1
				s += chr(data[objectsOffset] & 0x7F)
				print(s)
				objectsOffset += 1
		elif objectID == 0x836:
			width = data[objectsOffset]
			height = data[objectsOffset+1]
			print('Image %dx%d' % (width*8,height))
			objectsOffset += 3
			imgSize = 0
			imgSize += width * height
			imgSize += (width * (((height - 1) >> 3) + 1)) << 1
			objectsOffset += imgSize
			while data[objectsOffset] != 0:
				print('X:%d,Y:%d' % (data[objectsOffset], data[objectsOffset+1]))
				objectsOffset += 2
			objectsOffset += 1
		elif objectID == 0x000:
			print('END')
			objectsOffset += 2
			break
		else:
			print('%#04x' % objectID)
			sys.exit(1)
	print()

def parseRooms(data,roomOffset=0x100):
	roomIndex = 0
	while (data[roomOffset] & 0x40) == 0x00:
		print('Room #%d' % (roomIndex))
		if (data[roomOffset] & 0xf0):
			print('Flags:    %#x' % (data[roomOffset] & 0xf0))
		print('Color:    %s' % C64_COLORS[data[roomOffset] & 0xf])
		print('Position: %d,%d' % (data[roomOffset+1],data[roomOffset+2]))
		print('Size:     %d,%d' % ((data[roomOffset+3] >> 3) & 7,data[roomOffset+3] & 7))
		doorsOffset = struct.unpack('<H', data[roomOffset+4:roomOffset+6])[0] - BASE_ADDR
		objectsOffset = struct.unpack('<H', data[roomOffset+6:roomOffset+8])[0] - BASE_ADDR
		print('Doors:    %#x' % doorsOffset)
		#print('Objects:  %#x' % objectsOffset)
		print()
		parseObjects(data,objectsOffset)
		roomOffset += 8
		roomIndex += 1

def parseCastle(data):
	size = struct.unpack('<H', data[0x00:0x02])[0]
	if size != len(data):
		#print('Wrong filesize %#x / %#x' % (size, len(data)))
		#sys.exit(2)
		#return
		pass
	castleFlags = data[0x02]
	print('Flags:             %#x' % castleFlags)
	print('Player Start Room: #%d, #%d' % (data[0x03],data[0x04]))
	print('Player Start Door: #%d, #%d' % (data[0x05],data[0x06]))
	print('Player Lives:      %d, %d' % (data[0x07],data[0x08]))
	if False: # these are only useful during play or in saved games
		print('Player Room:       %#x, %#x' % (data[0x09],data[0x0a]))
		print('Player Door:       %#x, %#x' % (data[0x0b],data[0x0c]))
		print('Player State:      %#x, %#x' % (data[0x0d],data[0x0e]))
		print('Player Alive Flag: %#x, %#x' % (data[0x0f],data[0x10]))
		print('Unknown:           %#x' % (data[0x11]))
		print('Player Count:      %#x' % (data[0x12]))
		print('Player Key Count:  %#x, %#x' % (data[0x13],data[0x14]))
		print('Player Times:      %#x:%#x:%#x:%#x %#x:%#x:%#x:%#x' % (data[0x55],data[0x56],data[0x57],data[0x58], data[0x59],data[0x5a],data[0x5b],data[0x5c]))
		print('Unknown:           %#x, %#x' % (data[0x5d],data[0x5e]))
	outsideOffset = struct.unpack('<H', data[0x5f:0x61])[0] - BASE_ADDR
	print()
	if (castleFlags & 0x80) and outsideOffset != 0x0000:
		print('Escaped from the Castle:')
		parseObjects(data,outsideOffset)

for pathname in sorted(glob.glob('./The Castles of Dr. Creep/z*.prg')):
	filename = os.path.splitext(os.path.basename(pathname))[0][1:].upper()
	print('=' * len(filename))
	print(filename)
	print('=' * len(filename))
	data = open(pathname,'rb').read()
	baseAddr = struct.unpack('<H', data[0:2])[0]
	if baseAddr != BASE_ADDR:
		print('Wrong level start')
		sys.exit(1)
	data = data[2:] # strip the base address

	parseCastle(data)
	parseRooms(data)
