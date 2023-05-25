from typing import List


def is_visible(grid, x, y):
    nrow = len(grid)
    ncol = len(grid[x])

    # Tree on the edge
    if x in (0, nrow - 1) or y in (0, ncol - 1):
        return True

    tree_size = int(grid[x][y])

    left = [int(grid[x][col]) for col in range(y)]
    right = [int(grid[x][col]) for col in range(y + 1, ncol)]
    above = [int(grid[row][y]) for row in range(x)]
    below = [int(grid[row][y]) for row in range(x + 1, nrow)]

    return tree_size > min(max(left), max(right), max(above), max(below))


def compute_score(tree_size, neighbour_sizes):
    score = 0
    for neighbour_size in neighbour_sizes:
        score += 1
        if tree_size <= neighbour_size:
            return score
    return score


def productory(lst):
    prod = 1
    for x in lst:
        prod *= x
    return prod


def scenic_score(grid, x, y):
    nrow = len(grid)
    ncol = len(grid[x])

    tree_size = int(grid[x][y])

    left = reversed([int(grid[x][col]) for col in range(y)])
    right = [int(grid[x][col]) for col in range(y + 1, ncol)]
    above = reversed([int(grid[row][y]) for row in range(x)])
    below = [int(grid[row][y]) for row in range(x + 1, nrow)]

    return productory(
        compute_score(tree_size, neighbour_sizes)
        for neighbour_sizes in (left, right, above, below)
    )


def parse_input() -> List[str]:
    with open("input.txt") as file:
        inp = file.read().splitlines()

    return inp


def create_score_grid(score_function):
    tree_grid = parse_input()
    visible_grid = []
    n_row = len(tree_grid)
    for x in range(n_row):
        n_col = len(tree_grid[x])
        visible_grid.append([False for _ in range(n_col)])
        for y in range(n_col):
            visible_grid[x][y] = score_function(tree_grid, x, y)

    return visible_grid


def part1():
    visible_grid = create_score_grid(is_visible)
    visible_trees = 0
    for row in visible_grid:
        visible_trees += sum(row)

    return visible_trees


def part2():
    score_grid = create_score_grid(scenic_score)
    max_ = -float("inf")
    for row in score_grid:
        max_row = max(row)
        if max_row > max_:
            max_ = max_row
    return max_


if __name__ == "__main__":
    print(part1())
    print(part2())
