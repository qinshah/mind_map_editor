class Node {
  final String id;
  String title;
  bool titleUnedited;
  Children? children;

  List<Node> get childNodes => children?.attached ?? [];

  Node({
    required this.id,
    required this.title,
    this.titleUnedited = false,
    this.children,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'] as String,
      title: json['title'] as String,
      titleUnedited: json['titleUnedited'] as bool? ?? false,
      children: json['children'] == null
          ? null
          : Children.fromJson(json['children'] as Map<String, dynamic>),
    );
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

  factory Children.fromJson(Map<String, dynamic> json) {
    return Children(
      attached: (json['attached'] as List)
          .map((e) => Node.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'attached': attached.map((e) => e.toJson()).toList()};
  }
}

class Xmind {
  final Node root;

  Xmind({required this.root});

  Xmind.empty() : root = Node(id: 'root', title: '中心节点');

  factory Xmind.fromJson(List<dynamic> json) {
    return Xmind(
      root: Node.fromJson(json[0]['rootTopic'] as Map<String, dynamic>),
    );
  }

  List<dynamic> toJson() {
    return [
      {'rootTopic': root.toJson()},
    ];
  }
}
