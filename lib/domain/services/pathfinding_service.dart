import 'dart:collection';
import '../models/grid.dart';

abstract class PathfindingService {
  List<Position> findPath(Grid grid, Position start, Position goal);
}

class AStarPathfindingService implements PathfindingService {
  @override
  List<Position> findPath(Grid grid, Position start, Position goal) {
    final openSet = HashSet<Position>();
    final closedSet = HashSet<Position>();
    final cameFrom = <Position, Position>{};
    final gScore = <Position, double>{};
    final fScore = <Position, double>{};

    openSet.add(start);
    gScore[start] = 0;
    fScore[start] = _heuristic(start, goal);

    while (openSet.isNotEmpty) {
      Position current = _getLowestFScore(openSet, fScore);

      if (current == goal) {
        return _reconstructPath(cameFrom, current);
      }

      openSet.remove(current);
      closedSet.add(current);

      for (final neighbor in grid.getNeighbors(current)) {
        if (closedSet.contains(neighbor)) {
          continue;
        }

        final tentativeGScore = gScore[current]! + 1;

        if (!openSet.contains(neighbor)) {
          openSet.add(neighbor);
        } else if (tentativeGScore >= gScore[neighbor]!) {
          continue;
        }

        cameFrom[neighbor] = current;
        gScore[neighbor] = tentativeGScore;
        fScore[neighbor] = gScore[neighbor]! + _heuristic(neighbor, goal);
      }
    }

    return []; // No path found
  }

  double _heuristic(Position a, Position b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs().toDouble();
  }

  Position _getLowestFScore(
      HashSet<Position> openSet, Map<Position, double> fScore) {
    return openSet.reduce((a, b) => fScore[a]! < fScore[b]! ? a : b);
  }

  List<Position> _reconstructPath(
      Map<Position, Position> cameFrom, Position current) {
    final path = <Position>[current];
    while (cameFrom.containsKey(current)) {
      current = cameFrom[current]!;
      path.insert(0, current);
    }
    return path;
  }
} 