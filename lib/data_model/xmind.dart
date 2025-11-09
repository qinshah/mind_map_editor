import 'package:mind_map_editor/data/const.dart';
import 'package:mind_map_editor/data/path_const.dart';
import 'package:mind_map_editor/data_model/mind_map_node.dart';
import 'package:mind_map_editor/function/file_manager.dart';

// 扩展
final _imgStartPath = PathConst.root.join([PathConst.resName]);

extension XNodeExt on XNode {
  String? get imgPath {
    if (image == null) return null;
    return FM.supportPath(
      _imgStartPath.join([image!.src.substring('xap:resources/'.length)]),
    );
  }
}

class XNode extends MindMapNode {
  @override
  final String id;
  String title;
  bool titleUnedited;
  Children children;

  NodeImg? image;

  XNode({
    required this.id,
    required this.image,
    required this.title,
    this.titleUnedited = false,
    required this.children,
  });

  XNode.newInsert()
    : id = Const.uuid.v4(),
      title = '新节点',
      titleUnedited = false,
      children = Children(attached: []),
      image = null;

  XNode.root()
    : id = Const.uuid.v4(),
      title = '根节点',
      titleUnedited = false,
      children = Children(attached: []),
      image = null;

  factory XNode.fromJson(Map<String, dynamic> json) {
    final node = XNode(
      image: NodeImg.fromJson(json['image']),
      id: json['id'],
      title: json['title'],
      titleUnedited: json['titleUnedited'] ?? false,
      children: Children.fromJson(json['children']),
    );
    return node;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (image != null) 'image': image!.toJson(),
      'titleUnedited': titleUnedited,
      if (children.attached.isNotEmpty) 'children': children.toJson(),
    };
  }

  @override
  List<XNode> get subNodes => children.attached;
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
  List<XNode> attached;

  Children({required this.attached});

  factory Children.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Children(attached: []);
    final attachedMaps = json['attached'] as List;
    return Children(
      attached: List.generate(attachedMaps.length, (index) {
        return XNode.fromJson(attachedMaps[index]);
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {'attached': attached.map((e) => e.toJson()).toList()};
  }
}

class Xmind {
  final XNode root;

  Xmind({required this.root});

  Xmind.empty() : root = XNode.root();

  factory Xmind.fromJson(List<dynamic> json) {
    return Xmind(
      root: XNode.fromJson(json[0]['rootTopic'] as Map<String, dynamic>),
    );
  }

  List<dynamic> toJson() {
    return [
      {'rootTopic': root.toJson()},
    ];
  }
}
