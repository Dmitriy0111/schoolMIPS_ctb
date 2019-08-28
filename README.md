# schoolMIPS_ctb
Other testbench for 00_simple schoolMIPS.

## Quickstart:
For loading project with git program:

    $ git clone https://github.com/Dmitriy0111/schoolMIPS_ctb.git
    $ cd schoolMIPS_ctb 
    $ git checkout 00_simple
    $ git submodule update --init --recursive 

Or download project from GitHub site <a href="https://github.com/Dmitriy0111/schoolMIPS_ctb">00_simple</a>

**Impotant:** Before starting simulation process make compilation program.

## Compilation program:
*   **set PROG_NAME="name of folder with main program"** is used for setting current program. For example "set PROG_NAME=01_fibonacci";
*   **make prog_comp** is used for compiling program;
*   **make prog_clean** is used for cleaning compilation results folder.

## Simulation:
*   **make sim_dir** is used for creating simulation folder;
*   **make sim_clean** is used for cleaning simulation results folder;
*   **make sim_cmd** is used for starting simulation in command line (CMD) mode;
*   **make sim_gui** is used for starting simulation in graphical user interface (GUI) mode.
