==============================================================================
Spatial and Transformational Invariants for Natural Movies
==============================================================================

Thanks for downloading/viewing this code!

This code is provided to accompany the research project:
    "Learning Spatial and Transformational Invariants for Intermediate Visual Representation"
        by Charles F. Cadieu and Bruno A. Olshausen

The code is written in Matlab.

Please contact me if you find this code useful, find any bugs, or would like to suggest an improvement.

My email can be found here:

http://charles.cadieu.us/

Thanks,
 Charles Cadieu

==========================
Getting started
==========================

Download the code here:
 https://github.com/cadieu/twolayer

Get the data here:
 http://redwood.berkeley.edu/cadieu/data/vid075-chunks.tar.gz

under linux:
::

    wget http://redwood.berkeley.edu/cadieu/data/vid075-chunks.tar.gz .
    tar -zxf vid075-chunks.tar.gz twolayer/data/vid075-chunks

where 'twolayer' is the place where you placed the code.

I recommend starting with the learning script:
::

    run_8.m

This code will learn the firstlayer basis functions and the phase transformation components and the amplitude components. It runs on 8x8 image patches, so you will not be able to see too much structure in the second layer functions. run_20.m works for 20x20 image patches.

Note that you do not need to compile any C/mex functions in the subdirectories for the twolayer code to run.

.. figure:: https://redwood.berkeley.edu/cadieu/pubs/figures/firstlayer_20.png
   :scale: 30 %
   :alt: learned firstlayer functions

   Running run_20.m will produce 400 learned firstlayer functions.

.. figure:: https://redwood.berkeley.edu/cadieu/pubs/figures/twolayer_20.png
   :scale: 50 %
   :alt: learned secondlayer functions

   Running run_20.m will produce amplitude components (top) and phase transformation components (bottom).

==========================
Data
==========================

We have used a collection of nature documentary movies kindly provided by Hans van Hateren. Feel free to swap in your own data!

==========================
Notes on the code
==========================

The structure "m" contains the learned model parameters. The structure "p" contains the parameters for a given model. These structures contain the following variables:

::

   m - struct containing the basis function variables
     m.patch_sz - image domain patch size (side length of square patch)
     m.M - whitened domain dimensions
     m.N - firstlayer basis function dimensions
     m.L - phase transformation basis functions dimensions
     m.K - amplitude basis function dimensions
     m.t - number of learning iterations
     
     m.A - first layer complex basis functions (m.M x m.N)
     m.D - second layer transformation components (m.N x m.L)
     m.B - second layer amplitude components (m.N x m.K)
     
::

   p - struct containing the learning, inference, and other parameters
     p.firstlayer - first layer complex basis function parameters
     p.ampmodel - second layer amplitude component parameters
     p.phasetrans - second layer phase transformation parameters

The learning procedure in run_8.m and run_20.m is as follows:
       1. Initialize parameters
       2. Estimate whitening transform
       3. Learn first layer complex basis functions
       4. Infer large batch of first layer coefficients
       5. Learn second layer phase transformation components
       6. Learn second layer amplitude components
       7. Display the results

The code has not been overly optimized for speed. It is likely that the learning step sizes and iterations could be tweaked to increase the speed of convergence. Techniques that would increase the speed of inference and learning in this algorithm would be a valuable contribution. Maybe you have some ideas?

==========================
Using a GPU
==========================

This code supports the Jacket package from Accelereyes to use a GPU. This is useful for large image patches (greater than 16x16), and makes it possible to learn models on 32x32 image patches in a reasonable amount of time. You can get a trial license here:

 http://www.accelereyes.com/products/jacket

To enable the use of Jacket in the code, set the variable p.use_gpu (it is currently set to 0):

::

    p.use_gpu = 1;

==========================
Code Acknowledgements
==========================

This package utilizes code graciously provided by other authors. Please refer to their distributions for the latest and unmodified code.

    * Mark Schmidt          - tools/minFunc_ind/ (with modifications by Jascha Sohl-Dickstein)
    * Carl Edward Rasmussen - tools/minimize.m, tools/check.m
    * Yan Karklin           - tools/cjet.m, tools/subp.m
    * Daniel Eaton          - tools/sfigure.m
    * John Iversen          - tools/freezeColors.m


==========================
Citing this code
==========================

We expect to publish a journal article of our work soon. Until then, if you would like to reference this code in a publication, please cite this conference paper:

    Cadieu, CF., BA. Olshausen. Learning Transformational Invariants from Natural Movies. Neural Information Processing Systems (NIPS), 21:209-216, 2009.

::

	@incollection{CadieuNIPS2009,
	Author = {Cadieu, C. and Olshausen, B.},
	Booktitle = {Advances in Neural Information Processing Systems 21},
	Date-Added = {2009-11-22 21:35:48 -0800},
	Date-Modified = {2009-11-22 21:35:48 -0800},
	Editor = {D. Koller and D. Schuurmans and Y. Bengio and L. Bottou},
	Pages = {209--216},
	Publisher = {MIT Press},
	Title = {Learning Transformational Invariants from Natural Movies},
	Year = {2009}
	}


