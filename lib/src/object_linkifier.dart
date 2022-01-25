import 'package:linkify/linkify.dart';
import 'utils.dart';

RegExp _buildObjectRegex(String prefix) {
  return RegExp(
    r'^(.*?)(?<![\w'+prefix+r'])'+prefix+r'([\w'+prefix+r']+(?:[.!][\w'+prefix+r']+)*)',
    caseSensitive: true,
    dotAll: true,
  );
}

class ObjectLinkifier extends Linkifier {
  final String prefix;

  ObjectLinkifier(this.prefix) {
    objectRegex = _buildObjectRegex(prefix);
  }

  late RegExp objectRegex;

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];
    for (var element in elements) {
      if (element is TextElement) {
        final match = objectRegex.firstMatch(element.text);

        if (match == null || !match.group(2).isDigit()) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            list.add(ObjectElement('$prefix${match.group(2)!}'));
          }

          if (text.isNotEmpty) {
            list.addAll(parse([TextElement(text)], options));
          }
        }
      } else {
        list.add(element);
      }
    }
    return list;
  }
}

/// Represents an element containing an user tag
class ObjectElement extends LinkableElement {
  final String object;

  ObjectElement(this.object) : super(object, object);

  @override
  String toString() {
    return "ObjectElement: '$object' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) =>
      other is ObjectElement && super.equals(other) && other.object == object;
}
