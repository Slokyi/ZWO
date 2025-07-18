import { Component, OnInit, AfterViewInit, ViewChild, ElementRef } from '@angular/core';
import { DataSet, Network } from 'vis-network';

@Component({
  selector: 'app-relationship-graph',
  templateUrl: './relationship-graph.component.html',
  styleUrls: ['./relationship-graph.component.css']
})
export class RelationshipGraphComponent implements OnInit, AfterViewInit {
  @ViewChild('networkContainer') networkContainer!: ElementRef;
  @ViewChild('searchInput') searchInput!: ElementRef;
  private network!: Network;
  private nodes = new DataSet<any>();
  private edges = new DataSet<any>();
  private originalNodeColors: Record<number, any> = {};
  private originalEdgeColors: Record<number, any> = {};

  ngOnInit(): void {
    // 初始化数据
    this.initializeData();
  }

  ngAfterViewInit(): void {
    // 初始化网络
    this.initializeNetwork();
    // 保存原始颜色
    this.saveOriginalColors();
    // 绑定事件
    this.bindEvents();
  }

  private initializeData(): void {
    // 节点数据
    this.nodes.add([
      { id: 1, label: '节点 A' },
      { id: 2, label: '节点 B' },
      { id: 3, label: '节点 C' },
      { id: 4, label: '节点 D' },
      { id: 5, label: '节点 E' },
      { id: 6, label: '节点 F' },
      { id: 7, label: '节点 G' }
    ]);

    // 边数据
    this.edges.add([
      { from: 1, to: 2, arrows: 'to' },
      { from: 1, to: 3, arrows: 'to' },
      { from: 2, to: 4, arrows: 'to' },
      { from: 3, to: 4, arrows: 'to' },
      { from: 4, to: 5, arrows: 'to' },
      { from: 5, to: 6, arrows: 'to' },
      { from: 6, to: 7, arrows: 'to' },
      { from: 7, to: 5, arrows: 'to' } // 循环关系
    ]);
  }

  private initializeNetwork(): void {
    const container = this.networkContainer.nativeElement;
    const data = { nodes: this.nodes, edges: this.edges };
    const options = {
      nodes: {
        shape: 'ellipse',
        size: 25,
        font: { size: 14 },
        borderWidth: 1
      },
      edges: {
        width: 2,
        color: { inherit: 'from' },
        smooth: false
      },
      interaction: {
        dragNodes: true,
        zoomView: true,
        dragView: true
      },
      physics: {
        forceAtlas2Based: {
          gravitationalConstant: -26,
          centralGravity: 0.005,
          springLength: 230
        },
        minVelocity: 0.75,
        solver: 'forceAtlas2Based'
      }
    };

    this.network = new Network(container, data, options);
  }

  private saveOriginalColors(): void {
    this.nodes.forEach(node => {
      this.originalNodeColors[node.id] = node.color || { background: '#97C2FC', border: '#2B7CE9' };
    });

    this.edges.forEach(edge => {
      this.originalEdgeColors[edge.id] = edge.color || { color: '#848484', highlight: '#848484' };
    });
  }

  private bindEvents(): void {
    // 节点点击事件
    this.network.on('click', (params: any) => {
      if (params.nodes.length > 0) {
        this.highlightRelatedNodes(params.nodes[0]);
      } else {
        this.resetAllStyles();
      }
    });

    // 拖拽结束事件
    this.network.on('dragEnd', (params: any) => {
      if (params.nodes.length > 0) {
        const nodeId = params.nodes[0];
        this.nodes.update({ id: nodeId, fixed: true });
      }
    });

    // 搜索框事件
    this.searchInput.nativeElement.addEventListener('input', (e: Event) => {
      const searchTerm = (e.target as HTMLInputElement).value.toLowerCase().trim();
      this.handleSearch(searchTerm);
    });
  }

  private findRelatedNodes(startNodeId: number, visited = new Set<number>()): Set<number> {
    if (visited.has(startNodeId)) return visited;

    visited.add(startNodeId);

    // 查找所有出边相关节点
    this.edges.forEach(edge => {
      if (edge.from === startNodeId && !visited.has(edge.to)) {
        this.findRelatedNodes(edge.to, visited);
      }
    });

    // 查找所有入边相关节点
    this.edges.forEach(edge => {
      if (edge.to === startNodeId && !visited.has(edge.from)) {
        this.findRelatedNodes(edge.from, visited);
      }
    });

    return visited;
  }

  private highlightRelatedNodes(nodeId: number): void {
    this.resetAllStyles();

    if (!nodeId) return;

    const relatedNodes = this.findRelatedNodes(nodeId);

    // 高亮相关节点
    relatedNodes.forEach(id => {
      this.nodes.update({
        id: id,
        color: { background: '#FFD700', border: '#FFA500' },
        borderWidth: 3
      });
    });

    // 高亮相关边
    this.edges.forEach(edge => {
      if (relatedNodes.has(edge.from) && relatedNodes.has(edge.to)) {
        this.edges.update({
          id: edge.id,
          color: { color: '#FFA500', highlight: '#FFA500' },
          width: 3
        });
      }
    });
  }

  private resetAllStyles(): void {
    this.nodes.forEach(node => {
      this.nodes.update({
        id: node.id,
        color: this.originalNodeColors[node.id],
        borderWidth: 1
      });
    });

    this.edges.forEach(edge => {
      this.edges.update({
        id: edge.id,
        color: this.originalEdgeColors[edge.id],
        width: 2
      });
    });
  }

  private handleSearch(searchTerm: string): void {
    if (searchTerm === '') {
      this.resetAllStyles();
      return;
    }

    const matchingNodes = this.nodes.get().filter(node =>
      node.label.toLowerCase().includes(searchTerm)
    );

    this.resetAllStyles();

    matchingNodes.forEach(node => {
      this.nodes.update({
        id: node.id,
        color: { background: '#32CD32', border: '#228B22' },
        borderWidth: 3
      });
    });
  }
}
