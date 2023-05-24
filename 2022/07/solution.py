from __future__ import annotations
from collections import defaultdict
from typing import Set


class Node:
    def __init__(self, name: str, index: int, parent: Node = None) -> None:
        self.index = index
        self.name = name
        self.parent = parent
        self.subdir: set[Node] = set()
        self.contents = defaultdict(int)

    def get_parent(self) -> Node:
        return self.parent

    def add_subdir(self, dir: Node):
        self.subdir.add(dir)

    def cd(self, target) -> Node:
        for subdir in self.subdir:
            if subdir.name == target:
                return subdir

    def add_file(self, filename: str, size: int):
        filepath = self.pwd() + "/" + filename
        self.contents[filepath] = size

    def get_dir_size(self):
        return sum(self.contents.values())

    def get_total_dir_size(self):
        dir_size = self.get_dir_size()
        if not self.subdir:
            return dir_size

        return dir_size + sum(children.get_total_dir_size() for children in self.subdir)

    def pwd(self):
        if self.parent is None:
            return self.name
        return self.parent.pwd() + "/" + self.name

    def __repr__(self) -> str:
        self.pwd()


def is_command(s: str):
    return s[0] == "$"


def parse_input() -> Set[Node]:
    cwd: Node = None
    root = Node(name="/", index=0)
    index = None
    all_nodes = {root}
    with open("input.txt") as file:
        for line in file:
            if is_command(line):
                if "cd" in line:
                    target = line.split()[-1]
                    if target == "..":
                        cwd = cwd.get_parent()
                        index -= 1
                    elif target == "/":
                        cwd = root
                        index = 0
                    else:
                        cwd = cwd.cd(target)
                        index += 1

            else:
                if "dir" in line:
                    dir_name = line.split()[-1]
                    new_dir = Node(name=dir_name, index=index + 1, parent=cwd)
                    all_nodes.add(new_dir)
                    cwd.add_subdir(new_dir)
                else:
                    size, filename = line.split()
                    size = int(size)
                    cwd.add_file(filename=filename, size=size)

    return all_nodes


def part1():
    all_nodes = parse_input()
    file_sizes = {node.pwd(): node.get_total_dir_size() for node in all_nodes}
    return sum(v for v in file_sizes.values() if v <= 100000)


def part2():
    all_nodes = parse_input()
    file_sizes = {node.pwd(): node.get_total_dir_size() for node in all_nodes}
    total_space = 70000000
    needed_space = 30000000
    used_space = file_sizes["/"]
    unused_space = total_space - used_space

    min_deletion = needed_space - unused_space

    return min(v for v in file_sizes.values() if v >= min_deletion)


if __name__ == "__main__":
    print(part1())
    print(part2())
