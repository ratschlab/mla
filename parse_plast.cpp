#include <fstream>
#include <iostream>
#include <string>
#include <sstream>
#include <limits>
#include <cstdint>
#include <vector>

int main(int argc, char **argv) {
    size_t best_cov = std::numeric_limits<size_t>::max();
    size_t best_joint_cov = std::numeric_limits<size_t>::max();
    size_t start_pos = std::numeric_limits<size_t>::max();
    size_t last_pos = 0;

    size_t cur_start_pos;
    size_t cur_last_pos;

    std::ifstream fin(argv[1]);
    std::string line;
    std::string tag;
    std::string dummy;
    std::vector<std::string> labels;

    ssize_t cur_read = -1;
    ssize_t score = 0;

    while (std::getline(fin, line)) {
        std::istringstream sin(line);
        sin >> tag;
        if (tag == "Query") {
            if (last_pos > start_pos) {
                std::cout << cur_read << "\t" << score << "\t" << start_pos << "\t" << last_pos << "\t";
                if (labels.size()) {
                    std::cout << labels[0];
                    for (size_t i = 1; i < labels.size(); ++i) {
                        std::cout << ";" << labels[i];
                    }
                } else {
                    std::cout << "*";
                }
                std::cout << "\n";
            } else if (cur_read > -1) {
                std::cout << cur_read << "\t" << 0 << "\t" << 0 << "\t" << 0 << "\t*\n";
            }

            best_cov = 0;
            best_joint_cov = 0;
            labels.clear();
            start_pos = std::numeric_limits<size_t>::max();
            last_pos = 0;
            ++cur_read;
        } else if (tag == "Score:") {
            if (last_pos > start_pos) {
                std::cout << cur_read << "\t" << score << "\t" << start_pos << "\t" << last_pos << "\t";
                if (labels.size()) {
                    std::cout << labels[0];
                    for (size_t i = 1; i < labels.size(); ++i) {
                        std::cout << ";" << labels[i];
                    }
                } else {
                    std::cout << "*";
                }
                std::cout << "\n";
            }

            start_pos = std::numeric_limits<size_t>::max();
            last_pos = 0;
            labels.clear();
            sin >> score;
        } else if (tag == "Query:") {
            sin >> cur_start_pos >> dummy >> cur_last_pos;
            start_pos = std::min(start_pos, cur_start_pos - 1);
        } else if (tag == "Color") {
            sin >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> dummy >> cur_last_pos >> dummy >> dummy >> dummy >> dummy;
            last_pos = std::max(last_pos, cur_last_pos);
            best_joint_cov = std::max(best_joint_cov, last_pos - start_pos);
            size_t cur_cov = cur_last_pos - start_pos;
            best_cov = std::max(best_cov, cur_cov);
            labels.clear();
            while (sin >> dummy) {
                labels.emplace_back(dummy);
            }
        }
    }

    if (cur_read > -1) {
        if (last_pos > start_pos) {
            std::cout << cur_read << "\t" << score << "\t" << start_pos << "\t" << last_pos << "\t";
            if (labels.size()) {
                std::cout << labels[0];
                for (size_t i = 1; i < labels.size(); ++i) {
                    std::cout << ";" << labels[i];
                }
            } else {
                std::cout << "*";
            }
            std::cout << "\n";
        } else {
            std::cout << cur_read << "\t" << 0 << "\t" << 0 << "\t" << 0 << "\n";
        }
    }

    return 0;
}
