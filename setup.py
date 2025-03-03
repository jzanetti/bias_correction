from setuptools import setup, find_packages

setup(
    name="simple_bc",  # Name of your package on PyPI
    version="0.1.0",  # Version number (start with 0.1.0 for initial release)
    description="A simple package for bias correction",
    author="Sijin Zhang",
    author_email="zsjzyhzp@gmail.com",
    packages=find_packages(),  # Automatically finds your package (e.g., my_package)
    install_requires=["xgboost", "matplotlib", "pandas"],
    classifiers=[  # Metadata for PyPI
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    python_requires=">=3.9",  # Minimum Python version
)
