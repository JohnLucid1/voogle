## Overview

Welcome to Voogle - a tool to search for functions by types! This command-line tool provides a convenient way to search for functions based on return types and parameter types.

## Table of Contents

- [Installation](#installation)
- [Usage](#usage)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Installation

To install Voogle, follow these steps:

1. Clone the repository to your local machine:

   ```bash
   git clone https://github.com/your-username/voogle.git
   ```

2. Change into the project directory:

   ```bash
   cd voogle
   ```

3. Compile the programm

   ```bash
   v .
   ```

4. You're ready to use Voogle!

## Usage

Voogle utilizes command-line flags for ease of use. Use the following command:

```bash
voogle -p <filepath or dir> -i <search query>
```

Replace `<filepath or dir>` with the path or directory to start searching, and `<search query>` with your desired search query.

## Examples

### Example 1: Search for functions with a specific return type and parameters

```bash
voogle -p ./ -i "int|string, int"
```

This command will search for functions that return an integer and have two parameters: a string and an integer, starting from the current directory.

### Example 2: Search for functions with no return type and a single parameter

```bash
voogle -p ./ -i "|float"
```

This command will search for functions that do not have a specified return type and have a single parameter of type float, starting from the current directory.

## Contributing

If you'd like to contribute to Voogle, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them with descriptive commit messages.
4. Push your changes to your fork.
5. Create a pull request to the main repository's `develop` branch.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

Thank you for using Voogle! If you encounter any issues or have suggestions for improvement, feel free to open an issue on the GitHub repository. Happy coding!