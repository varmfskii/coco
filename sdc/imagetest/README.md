# Imagetest

A somewhat useful test for features of libsdc that performs a pmode4 slideshow.

'welcome' is used for any welcome test for the slideshow.

'frames' is the number of vsync frames to pause for each image.

If defined, 'images' is the number of images in each image file (if not this is based on the length of the image file)

The file imagelist.txt contains a list of image files.

## Image files

An image file is simply a number of 6,144 byte (6kb) pmode4 screens concatenated together.

If 'images' is not defined this must be a multiple of 6kb long.

Due to the way that the CoCoSDC mounts files, image files must be at least 81kb (82,944 bytes) long or if the number of images comes from the file length, 84kb (14 images in a file).

This should be able to handle at least 699,050 images in a single file.
