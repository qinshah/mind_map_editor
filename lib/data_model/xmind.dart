import 'package:mind_map_editor/data/path_const.dart';
import 'package:mind_map_editor/function/file_manager.dart';

// 扩展

final _imgStartPath = PathConst.root.join([PathConst.resName]);

extension NodeExt on Node {
  String? get imgPath {
    if (image == null) return null;
    return FM.supportPath(
      _imgStartPath.join([image!.src.substring('xap:resources/'.length)]),
    );
  }

  List<Node> get subNodes => children?.attached ?? [];
}

class Node {
  Node? parent;
  final String id;
  String title;
  bool titleUnedited;
  Children? children;

  NodeImg? image;

  Node({
    required this.parent,
    required this.id,
    required this.image,
    required this.title,
    this.titleUnedited = false,
    this.children,
  });

  factory Node.fromJson(
    Map<String, dynamic> json, {
    required List<int> path,
    required Node? parent,
  }) {
    final node = Node(
      parent: parent,
      image: NodeImg.fromJson(json['image']),
      id: json['id'] as String,
      title: json['title'] as String,
      titleUnedited: json['titleUnedited'] as bool? ?? false,
    );
    node.children = json['children'] == null
        ? null
        : Children.fromJson(
            parent: node,
            json['children'] as Map<String, dynamic>,
            parentPath: path,
          );
    return node;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (image != null) 'image': image!.toJson(),
      'titleUnedited': titleUnedited,
      if (children != null) 'children': children!.toJson(),
    };
  }
}

class NodeImg {
  String src;
  ImgAlign align;

  double? width;
  double? height;

  NodeImg({
    required this.src,
    required this.align,
    required this.width,
    required this.height,
  });

  static NodeImg? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return NodeImg(
      src: json['src'],
      align: switch (json['align']) {
        'top' => ImgAlign.top,
        'bottom' => ImgAlign.bottom,
        'left' => ImgAlign.left,
        'right' => ImgAlign.right,
        _ => ImgAlign.top,
      },
      width: double.tryParse(json['width'].toString()),
      height: double.tryParse(json['height'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'src': src,
    'align': align.name,
    if (width != null) 'width': width,
    if (height != null) 'height': height,
  };
}

enum ImgAlign { top, bottom, left, right }

class Children {
  final List<Node> attached;

  Children({required this.attached});

  factory Children.fromJson(
    Map<String, dynamic> json, {
    required List<int> parentPath,
    required Node? parent,
  }) {
    final attachedMaps = json['attached'] as List;
    return Children(
      attached: List.generate(attachedMaps.length, (index) {
        return Node.fromJson(
          attachedMaps[index],
          path: [...parentPath, index],
          parent: parent,
        );
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {'attached': attached.map((e) => e.toJson()).toList()};
  }
}

class Xmind {
  final Node root;

  Xmind({required this.root});

  Xmind.empty()
    : root = Node(id: 'root', title: '中心节点', image: null, parent: null);

  factory Xmind.fromJson(List<dynamic> json) {
    return Xmind(
      root: Node.fromJson(
        parent: null,
        json[0]['rootTopic'] as Map<String, dynamic>,
        path: [0],
      ),
    );
  }

  List<dynamic> toJson() {
    return [
      {'rootTopic': root.toJson()},
    ];
  }
}
