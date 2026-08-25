=========================
Git Submodule Dependencies
=========================

This file lists only the third-party components declared as Git submodules in
the ``djvu2pdf-docker`` repository.

The original ``djvu2pdf-docker`` materials are licensed separately under the
MIT License. The submodules listed below remain subject to their respective
licenses and are not relicensed under the project's MIT License.

Submodule inventory
===================

+--------------+-------------------------+---------------------+-----------------+
| Component    | Pinned commit           | License             | Notice files    |
+==============+=========================+=====================+=================+
| ImageMagick  | ``74f8154136d2f631ca3   | ImageMagick License | ``LICENSE``,    |
|              | e0421e6cf6c8dccd548f7`` |                     | ``NOTICE``      |
+--------------+-------------------------+---------------------+-----------------+
| ``djvu2pdf`` | ``798bc7e78d8408bc1ac   | MIT                 | ``LICENSE``     |
|              | 2eb307442526b88d356ad`` |                     |                 |
+--------------+-------------------------+---------------------+-----------------+
| ``jbig2enc`` | ``a4ff6b9191e1c824cbc   | Apache-2.0          | ``COPYING``,    |
|              | 36364cbeb12cab058b5da`` |                     | ``doc/PATENTS`` |
+--------------+-------------------------+---------------------+-----------------+

Notice directory
================

::

  THIRD-PARTY-NOTICES/
  ├── DEPENDENCIES.rst
  ├── ImageMagick-LICENSE
  ├── ImageMagick-NOTICE
  ├── djvu2pdf-LICENSE
  ├── jbig2enc-COPYING
  ├── jbig2enc-PATENTS
  └── Apache-2.0
