class Position {
  final int x;
  final int y;

  const Position(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Position &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class GridCell {
  final Position position;
  final bool isObstacle;
  final bool isStart;
  final bool isGoal;

  const GridCell({
    required this.position,
    this.isObstacle = false,
    this.isStart = false,
    this.isGoal = false,
  });

  GridCell copyWith({
    Position? position,
    bool? isObstacle,
    bool? isStart,
    bool? isGoal,
  }) {
    return GridCell(
      position: position ?? this.position,
      isObstacle: isObstacle ?? this.isObstacle,
      isStart: isStart ?? this.isStart,
      isGoal: isGoal ?? this.isGoal,
    );
  }
}

class Grid {
  final int rows;
  final int columns;
  final List<List<GridCell>> cells;

  Grid({
    required this.rows,
    required this.columns,
  }) : cells = List.generate(
          rows,
          (i) => List.generate(
            columns,
            (j) => GridCell(position: Position(i, j)),
          ),
        );

  bool isValidPosition(Position position) {
    return position.x >= 0 &&
        position.x < rows &&
        position.y >= 0 &&
        position.y < columns;
  }

  List<Position> getNeighbors(Position position) {
    final List<Position> neighbors = [];
    final List<List<int>> directions = [
      [-1, 0], // up
      [1, 0], // down
      [0, -1], // left
      [0, 1], // right
    ];

    for (final direction in directions) {
      final newX = position.x + direction[0];
      final newY = position.y + direction[1];
      final newPosition = Position(newX, newY);

      if (isValidPosition(newPosition) &&
          !cells[newX][newY].isObstacle) {
        neighbors.add(newPosition);
      }
    }

    return neighbors;
  }

  void setObstacle(Position position, bool isObstacle) {
    if (isValidPosition(position)) {
      cells[position.x][position.y] = cells[position.x][position.y].copyWith(
        isObstacle: isObstacle,
      );
    }
  }

  void setStart(Position position) {
    if (isValidPosition(position)) {
      // Clear previous start
      for (var row in cells) {
        for (var cell in row) {
          if (cell.isStart) {
            cells[cell.position.x][cell.position.y] =
                cell.copyWith(isStart: false);
          }
        }
      }
      cells[position.x][position.y] =
          cells[position.x][position.y].copyWith(isStart: true);
    }
  }

  void setGoal(Position position) {
    if (isValidPosition(position)) {
      // Clear previous goal
      for (var row in cells) {
        for (var cell in row) {
          if (cell.isGoal) {
            cells[cell.position.x][cell.position.y] =
                cell.copyWith(isGoal: false);
          }
        }
      }
      cells[position.x][position.y] =
          cells[position.x][position.y].copyWith(isGoal: true);
    }
  }
} 