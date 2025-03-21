# pyggwave python package

This README contains only development information, you can check out full README (README.rst) for the latest version of pyggwave python package on [pyggwave's PyPI page](https://pypi.org/project/pyggwave/).

README.rst is not commited to git because it is generated from [README-tmpl.rst](./README-tmpl.rst).


## Building

Run `make build` to generate an extension module as .so file.
You can test it then by importing it from python interpreter `import pyggwave` and running `pyggwave.encode('test')` (you have to be positioned in the directory where .so was built).
This is useful for testing while developing.

Run `make sdist` to create a source distribution, but not publish it - it is a tarball in dist/ that will be uploaded to pip on `publish`.
Use this to check that tarball is well structured and contains all needed files, before you publish.
Good way to test it is to run `sudo pip install dist/pyggwave-*.tar.gz`, which will try to install pyggwave from it, same way as pip will do it when it is published.

`make clean` removes all generated files.

README.rst is auto-generated from [README-tmpl.rst](./README-tmpl.rst), to run regeneration do `make README.rst`.
README.rst is also automatically regenerated when building package (e.g. `make build`).
This enables us to always have up to date results of code execution and help documentation of pyggwave methods in readme.

## Publishing

Remember to update version in setup.py before publishing.

To trigger automatic publish to PyPI, create a tag and push it to Github -> Travis will create sdist, build wheels, and push them all to PyPI while publishing new version.

You can also publish new version manually if needed: run `make publish` to create a source distribution and publish it to the PyPI.

## Acknowledgments

These Python bindings are generated by following [edlib](https://github.com/Martinsos/edlib) example
