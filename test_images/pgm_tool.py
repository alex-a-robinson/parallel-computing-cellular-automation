#!/usr/bin/env python

import re
import numpy as np

import argparse
import random
import time

def read_pgm(filename, byteorder='>'):
  '''Return image data from a raw PGM as numpy array'''
  with open(filename, 'rb') as f:
    buffer = f.read()
  try:
    header, width, height, maxval = re.search(
      b"(^P5\s(?:\s*#.*[\r\n])*"
      b"(\d+)\s(?:\s*#.*[\r\n])*"
      b"(\d+)\s(?:\s*#.*[\r\n])*"
      b"(\d+)\s(?:\s*#.*[\r\n]\s)*)", buffer).groups()
  except AttributeError:
    raise ValueError('Not a raw PGM file: "%s"' % filename)

  image = np.frombuffer(buffer,
                        dtype='u1' if int(maxval) < 256 else byteorder+'u2',
                        count=int(width) * int(height),
                        offset=len(header)
                        ).reshape((int(height), int(width)))

  # Normalise
  image = image / 255
  return image

def generate_pgm(width, mean, output_filename):
  binary_image = np.random.choice([0, 1], (width, width), p=[1-mean, mean])

  image = 255 * binary_image

  header = 'P5\n%(width)i %(height)i 255\n' % {'width': width, 'height': width}

  with open(output_filename, 'wb') as f:
    f.write(header)
    image.astype('u1').tofile(f)
    f.close()

  return binary_image

def show_image(image):
  '''Displays an image'''
  from matplotlib import pyplot
  pyplot.imshow(image, pyplot.cm.gray, interpolation='none')
  pyplot.show()

def print_stats(image):
  print('%(width)ix%(height)i, %(alive_cells)i/%(total_cells)i alive, ' \
        'mean: %(mean_alive).3f, var: %(var).3f, std: %(std).3f' %
        {
          'width': image.shape[0],
          'height': image.shape[1],
          'alive_cells': np.count_nonzero(image),
          'total_cells': image.size,
          'mean_alive': np.mean(image),
          'var': np.var(image),
          'std': np.std(image)
        })


parser = argparse.ArgumentParser(description='GoL map tool')

parser.add_argument('-f', '--filename', type=str,
                    help='Path to image')
parser.add_argument('-s', '--stats', action='store_true',
                    help='Print image stats')
parser.add_argument('-d', '--display', action='store_true',
                    help='Display image')
parser.add_argument('-g', '--generate', type=int,
                    help='Generate a map with specified height')
parser.add_argument('-m', '--mean', type=float,
                    help='Specify the mean to use for generation')
parser.add_argument('-o', '--output', type=str,
                    help='Output file name')
  
args = parser.parse_args()

if not args.filename and not args.generate:
  parser.error('Must use either --filename or --generate')

if args.filename and args.generate:
  parser.error('Can\'t use both --filename and --generate')

image = None

if args.filename is not None:
  image = read_pgm(args.filename, byteorder='<')

if args.generate:
  if args.mean is not None:
    mean = args.mean
  else:
    mean = random.random()

  if args.output is not None:
    output_filename = args.output
  else:
    output_filename = '%ix%i-%i' % (args.generate, args.generate, int(time.time()))

  image = generate_pgm(args.generate, mean, output_filename)

if args.stats: print_stats(image) 
if args.display: show_image(image)
