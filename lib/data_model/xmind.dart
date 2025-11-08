class Node {
  Node? parent;
  final String id;
  String title;
  bool titleUnedited;
  Children? children;

  List<Node> get childNodes => children?.attached ?? [];

  Node({
    required this.parent,
    required this.id,
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
      'titleUnedited': titleUnedited,
      if (children != null) 'children': children!.toJson(),
    };
  }
}

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
    : root = Node(id: 'root', title: '中心节点', parent: null);

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
