import 'package:mind_map_editor/xmind/xmind_const.dart';
import 'package:mind_map_editor/common/path_const.dart';
import 'package:mind_map_editor/mind_map/m_m_node.dart';
import 'package:mind_map_editor/common/function/file_manager.dart';

// 扩展
final _imgStartPath = PathConst.root.join([PathConst.resName]);

extension XnodeExt on Xnode {
  String? get imgPath {
    if (image == null) return null;
    return FM.supportPath(
      _imgStartPath.join([image!.src.substring('xap:resources/'.length)]),
    );
  }
}

class Xnode extends MMNode {
  @override
  final String id;
  String title;
  bool titleUnedited;
  Children children;

  XnodeImg? image;

  Xnode({
    required this.id,
    required this.image,
    required this.title,
    this.titleUnedited = false,
    required this.children,
  });

  Xnode.empty(this.title)
    : id = XmindConst.uuid.v4(),
      titleUnedited = false,
      children = Children(attached: []),
      image = null;

  factory Xnode.fromJson(Map<String, dynamic> json) {
    final node = Xnode(
      image: XnodeImg.fromJson(json['image']),
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
  List<Xnode> get subNodes => children.attached;
}

class XnodeImg {
  String src;
  ImgAlign align;

  double? width;
  double? height;

  XnodeImg({
    required this.src,
    required this.align,
    required this.width,
    required this.height,
  });

  static XnodeImg? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    return XnodeImg(
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
  List<Xnode> attached;

  Children({required this.attached});

  factory Children.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Children(attached: []);
    final attachedMaps = json['attached'] as List;
    return Children(
      attached: List.generate(attachedMaps.length, (index) {
        return Xnode.fromJson(attachedMaps[index]);
      }),
    );
  }

  Map<String, dynamic> toJson() {
    return {'attached': attached.map((e) => e.toJson()).toList()};
  }
}

class Xmind {
  final Xnode root;

  Xmind({required this.root});

  Xmind.empty() : root = Xnode.empty('根节点');

  factory Xmind.fromJson(List<dynamic> json) {
    return Xmind(
      root: Xnode.fromJson(json[0]['rootTopic'] as Map<String, dynamic>),
    );
  }

  List<dynamic> toJson() {
    return [
      {'rootTopic': root.toJson()},
    ];
  }
}
