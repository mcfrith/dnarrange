import setuptools

commitInfo = "$Format:%d$".strip("( )").split()
version = commitInfo[commitInfo.index("tag:") + 1].rstrip(",")

setuptools.setup(
    name="dnarrange",
    version=version,
    description='Find rearrangements in "long" DNA reads relative to a genome sequence',
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    url="https://github.com/mcfrith/dnarrange",
    classifiers=[
        "Intended Audience :: Science/Research",
        "Topic :: Scientific/Engineering :: Bio-Informatics",
        "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
    ],
    scripts=[
        "dnarrange",
        "dnarrange-genes",
        "dnarrange-link",
        "dnarrange-merge",
        "last-multiplot",
    ],
)
