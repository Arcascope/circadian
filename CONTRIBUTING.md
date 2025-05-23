# Contributing to circadian


<!-- WARNING: THIS FILE WAS AUTOGENERATED! DO NOT EDIT! -->

Thanks for contributing to `circadian`! We welcome issues, pull
requests, and comments on GitHub. Please read the following guidelines
for more details on how to contribute.

# General workflow

Before adding any new code to `circadian` it’s useful to create your own
fork of the repository and a dedicated Python environment.

To create a fork navigate to <https://github.com/Arcascope/circadian>
and click on the Fork button on the top right corner of the repository
page. This will create a copy of the repository in your own GitHub
account. Then, you can clone the fork to your local machine. For more
details on creating a fork, cloning, and syncing it with Arcascope’s
repo see [this Github
doc](https://docs.github.com/en/get-started/quickstart/fork-a-repo).

A dedicated Python environment is useful when developing and testing
`circadian` because it maintains a clean separation between your changes
to `circadian` and any other installation you might have of it. We
include a `dev_requirements.txt` file in `circadian`’s main directory
that you can use to install these packages. We recommend you create a
new Python environment and install these packages there.

``` bash
pip install -r dev_requirements.txt
```

See some [guidelines](https://docs.python.org/3/library/venv.html) on
virtual environments for further information.

Additionally, it’s useful to install your local version of `circadian`
in this environment. You can do this by running:

``` bash
cd path/to/circadian
pip install -e .
```

This ensures that you’ll be using your local version of `circadian` when
you run and test your code.

A complete workflow for setting up a development environment would look
like this:

``` bash
# 1. Fork Arcascope's circadian repository on GitHub
# 2. Clone your fork to your local machine
git clone https://github.com/YOUR_USERNAME/circadian.git
# 3. Create a dedicated python environment
python -m venv circadian_dev_env
# 4. Activate the environment (this step depends on your OS)
source circadian_dev_env/bin/activate
# 5. Install requirements
pip install -r circadian/dev_requirements.txt
# 6. Install your local circadian code in editable mode
pip install -e circadian
# 7. If you don't have it, install quarto
nbdev_install_quarto
```

# Adding new code to circadian - `nbdev`

`circadian` is developed using `nbdev` by
[fast.ai](https://nbdev.fast.ai/) which allows users to create a python
package and its documentation by writing Jupyter notebooks. We recommend
checking out `nbdev`’s [end-to-end
walkthrough](https://nbdev.fast.ai/tutorials/tutorial.html) to get a
better understanding of how it works. Therefore, you’ll need a code
editor that supports Jupyter notebooks to contribute to `circadian`.

All the `.py` source files of `circadian` (located at
`circadian/circadian`) are automatically generated by `nbdev` from the
notebooks in the `circadian/nbs` folder. Additionally, these notebooks
are the primary documentation for the package (generated with
[Quarto](https://quarto.org/)). Therefore, as a developer you’ll be
mainly modifying the notebooks in the `nbs` folder (`nbdev` will take
care of generating the corresponding `.py` files).

## Example

Let’s assume we want to add a new feature to `circadian` for calculating
the average sleep duration of a person given a set of timepoints and
sleep states. This new feature will add a new function called
`average_sleep_duration` to the `utils` module of `circadian`. First, we
need to create a new branch for this feature. We can do this by running
the following command in the terminal:

``` bash
git checkout -b avg-sleep-duration
```

Then, we open the notebook corresponding to the `utils` module which is
located at `circadian/nbs/api/07_utils.ipynb`. We can see that the
notebook contains many cells at the top where we import python packages,
then a couple of function definitions, and finally a cell where we tell
`nbdev` to export the code in this notebook to `.py` files. We will add
our code just before this final cell.

We create a new cell and add the following code to it:

``` python
#| export
#| hide
def average_sleep_duration(time: np.ndarray, # time array in hours
                           sleep: np.ndarray # sleep/wake information. 1 for sleep, 0 for wake
                           ) -> float: # average sleep duration in hours
    "Calculate the average sleep duration from a sleep/wake array."
    # input validation
    if not isinstance(time, np.ndarray):
        raise TypeError("time must be a numpy array")
    if not isinstance(sleep, np.ndarray):
        raise TypeError("sleep must be a numpy array")
    if time.shape != sleep.shape:
        raise ValueError("time and sleep must have the same shape")
    # calculate sleep duration
    sleep_starts = np.where(np.diff(sleep) == 1)[0]
    sleep_ends = np.where(np.diff(sleep) == -1)[0]
    sleep_durations = time[sleep_ends] - time[sleep_starts]
    return np.mean(sleep_durations)
```

Several things to notice:

- At the top of our cell we are including `nbdev`
  [directives](https://nbdev.fast.ai/explanations/directives.html).
  These are special comments that tell `nbdev` how to process the cell.
  In this case, we are telling `nbdev` to export (`#| export`) the cell
  to the `.py` source file and not to show (`#| hide`) the cell or its
  output in the documentation.
- We are using
  [type-hinting](https://mypy.readthedocs.io/en/stable/cheat_sheet_py3.html)
  to specify the type of the input and output of our function. This is
  not required, but it is good practice and will help us catch errors.
- After each function input and output we’re adding a comment explaining
  what the input/output is. This is important to generate good
  documentation. `nbdev` will automatically convert these comments into
  documentation for us when we build our documentation site. Similarly,
  the string after the function definition will be used as the
  function’s docstring.

Below this line we can add some text describing what our function does
and an example outlining how to use it. We do this by creating the
following three cells:

``` markdown
# Average sleep duration
This function calculates the average sleep duration for a dataset of sleep logs. For example,
```

``` python
time = np.linspace(0.0, 108.0, 100)
sleep = np.sin(2 * np.pi * time / 24.0)
sleep[sleep >= 0] = 0.0
sleep[sleep < 0] = 1.0
average_sleep = average_sleep_duration(time, sleep)
print(average_sleep) #| hide_line
```

``` python
#| echo: false
plt.plot(time / 24.0, sleep)
plt.axhline(y=averag_sleep, color='r', linestyle='--',
            label='Average sleep duration')
plt.xlabel('Time (days)')
plt.ylabel('Sleep state')
plt.show()
```

In this case:

- The first cell (in Markdown) will appear rendered as text in the
  documentation website
- The second cell will appear rendered as a code cell in the
  documentation website without the print statement (`#| hide_line`).
  However, below the cell we will see the output of print.
- The third cell will only show the final plot (`#| echo: false`). The
  code will not appear in the documentation but it’s output will.

Finally, we want to test that our function works properly. To do this we
head to `circadian/nbs/test/test_utils.ipynb` (or create it if it
doesn’t exist) and add the following cells:

``` python
#| hide 
%load_ext autoreload
%autoreload 2
```

``` python
import numpy as np
from fastcore.test import * # if not already present
from circadian.utils import average_sleep_duration
```

``` python
# test average_sleep_duration
time = np.linspace(0.0, 108.0, 100)
sleep = np.sin(2 * np.pi * time / 24.0)
sleep[sleep >= 0] = 0.0
sleep[sleep < 0] = 1.0
average_sleep = average_sleep_duration(time, sleep)
test_eq(np.isclose(average_sleep, 12.0), True)
# test input validation
test_fail(lambda: average_sleep_duration([1.0, 1.0], sleep), 
          contains="time must be a numpy array")
test_fail(lambda: average_sleep_duration(time, [1.0, 1.0]),
            contains="sleep must be a numpy array")
test_fail(lambda: average_sleep_duration(time, sleep[:-1]), 
          contains="time and sleep must have the same shape")
```

- The first cell tells IPython to reload imported modules before
  execution. It’s useful for development. See more details at [IPython’s
  documentation](https://ipython.org/ipython-doc/3/config/extensions/autoreload.html).
- `nbdev` requires import statements to be in different cells than code.
  So that’s why we have a separate imports cell.
- For testing, we can use `nbdev` functions to test our code such as
  `test_eq` and `test_fail`. See more details at [nbdev’s
  documentation](https://fastcore.fast.ai/test.html).

Once we are done writing our code, tests, and documentation we’re ready
to generate the source `.py` files and strip notebooks of innecessary
information. This is done by running the following command from the root
of the repository:

``` bash
nbdev_prepare
```

If the code in all notebooks is valid and no cell throws an error you
should see a `Success` output.

Then we can follow the usual `git` workflow to get our changes into our
fork:

``` bash
git add .
git commit -m "Add Average sleep calculation, tests, and docs"
git push --set-upstream origin avg-sleep-duration # This will create a new branch on our fork
```

Finally, we can open a pull request on GitHub to get our changes into
the main repository. Arcascope developers will review your pull request
and merge it into the main repository if everything looks good! Here’s
more info on [creating a pull
request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request).

Therefore, the steps to add a new feature to `circadian` using `nbdev`
are:

1.  Go to the notebook you want to modify or create a new one in the
    `nbs` folder
2.  Add your code with the proper directives and documentation
3.  Add your tests on `circadian/nbs/test/TEST_FILE.ipynb`
4.  Save notebooks and run `nbdev_prepare` from the root folder
5.  Commit and push your changes to GitHub
6.  Create a pull request to the `main` branch
7.  Wait for our review!
