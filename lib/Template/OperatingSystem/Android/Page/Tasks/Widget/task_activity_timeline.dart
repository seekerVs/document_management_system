import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';
import '../../../../../Utils/Firebase/firebase_utils.dart';
import '../../Activity/Model/activity_model.dart';
import '../../Signature/Model/signature_request_model.dart';
import '../../../../../Utils/Constant/enum.dart';
import '../../../../../Utils/Formatters/formatter.dart';

enum _NodeType { past, current, future }

class _NodeData {
  final _NodeType type;
  final String dateOrTitle;
  final String description;
  final bool isCompletedAction; // For the green checkmark

  _NodeData({
    required this.type,
    required this.dateOrTitle,
    required this.description,
    this.isCompletedAction = false,
  });
}

class TaskActivityTimeline extends StatelessWidget {
  final List<ActivityModel> activities;
  final SignatureRequestModel task;

  const TaskActivityTimeline({
    super.key,
    required this.activities,
    required this.task,
  });

  List<_NodeData> _buildNodes() {
    final nodes = <_NodeData>[];

    // 1. Add all past activities
    for (final act in activities) {
      nodes.add(
        _NodeData(
          type: _NodeType.past,
          dateOrTitle: AppFormatter.dateTime(act.timestamp),
          description: _getActivityLabel(act),
          isCompletedAction: act.action == ActivityAction.completed,
        ),
      );
    }

    // 2. Add pending/future states if the task is not complete
    if (task.status != SignatureRequestStatus.completed && !task.allSigned) {
      final currentEmail = FirebaseUtils.currentEmail;
      final currentUserSigner = task.signers
          .where((s) => s.signerEmail == currentEmail)
          .firstOrNull;

      String pendingDesc = 'Waiting for others to sign';
      if (currentUserSigner != null &&
          currentUserSigner.status == SignerStatus.pending) {
        pendingDesc = 'You need to sign';
      }

      // Add Current Node
      nodes.add(
        _NodeData(
          type: _NodeType.current,
          dateOrTitle: 'Current',
          description: pendingDesc,
        ),
      );

      // Add Future Node
      nodes.add(
        _NodeData(
          type: _NodeType.future,
          dateOrTitle: 'Task complete',
          description: '',
        ),
      );
    }

    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _buildNodes();

    if (nodes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timeline_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No activity yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Timeline.tileBuilder(
      padding: const EdgeInsets.symmetric(vertical: 20),
      theme: TimelineThemeData(
        nodePosition: 0,
        indicatorPosition: 0,
        connectorTheme: const ConnectorThemeData(thickness: 2.0),
      ),
      builder: TimelineTileBuilder.connected(
        itemCount: nodes.length,
        contentsBuilder: (context, index) {
          final node = nodes[index];

          return Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  node.dateOrTitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                if (node.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    node.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: node.type == _NodeType.future
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        indicatorBuilder: (context, index) {
          final node = nodes[index];
          Widget indicator;

          if (node.isCompletedAction) {
            indicator = DotIndicator(
              size: 16.0,
              color: Theme.of(context).colorScheme.tertiary,
              child: Icon(
                Icons.check,
                size: 10,
                color: Theme.of(context).colorScheme.onTertiary,
              ),
            );
          } else {
            switch (node.type) {
              case _NodeType.past:
                indicator = DotIndicator(
                  size: 10.0,
                  color: Theme.of(context).colorScheme.primary,
                );
                break;
              case _NodeType.current:
                indicator = DotIndicator(
                  size: 16.0,
                  color: Theme.of(context).colorScheme.primary,
                );
                break;
              case _NodeType.future:
                indicator = DotIndicator(
                  size: 10.0,
                  color: Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.3),
                );
                break;
            }
          }

          // Wrap indicator in a fixed-size box to ensure connectors align perfectly in the center
          return SizedBox(width: 20, child: Center(child: indicator));
        },
        connectorBuilder: (context, index, type) {
          // The connector leading downwards from a node.
          // index corresponds to the top node of the connector.
          final node = nodes[index];

          bool isGrey =
              node.type == _NodeType.current || node.type == _NodeType.future;

          return SolidLineConnector(
            color: isGrey
                ? Theme.of(
                    context,
                  ).colorScheme.outlineVariant.withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.primary,
          );
        },
      ),
    );
  }

  String _getActivityLabel(ActivityModel activity) {
    final actor = activity.actorName;
    switch (activity.action) {
      case ActivityAction.uploaded:
        return 'The document was created by $actor';
      case ActivityAction.requestedSignature:
        return '$actor requested a signature';
      case ActivityAction.signed:
        return '$actor signed the document';
      case ActivityAction.completed:
        return 'The document is fully signed';
      default:
        return '$actor performed an action: ${activity.action.name}';
    }
  }
}
