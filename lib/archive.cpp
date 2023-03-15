#include <iostream>
#include <cstdio>
#include <string>

int main()
{
	std::string tmp_dirname = "./archive/tmp";
	std::string tmp_filename = "./archive/tmp/index.pdf";
	std::string new_name, new_dirname, new_filename;
	std::cin >> new_name;
	new_filename = "./archive/tmp/" + new_name + ".pdf";
	new_dirname = "./archive/" + new_name;

	if (std::rename(tmp_filename.c_str(), new_filename.c_str()) != 0) {
		std::perror("Error: renaming file");
		return EXIT_FAILURE;
	}
	if (std::rename(tmp_dirname.c_str(), new_dirname.c_str()) != 0) {
		std::perror("Error: renaming file");
		return EXIT_FAILURE;
	}
}