import { AfterViewInit, Component, ElementRef, OnInit, ViewChild } from '@angular/core';
import { MessageService } from 'primeng/api';
import { DataSet } from 'vis-data';
import { Network } from 'vis-network';
import { Edge } from './edge';
import { IrisNetwork } from './network';
import { NetworkService } from './network.service';
import { Node } from './node';

@Component({
    templateUrl: './network.component.html',
    styleUrls: ['./network.css'],
    providers: [MessageService, NetworkService]
})
export class NetworkComponent implements OnInit, AfterViewInit {
    @ViewChild('visNetwork', { static: false }) visNetwork!: ElementRef;
    public networkInstance: Network = {} as Network;
    public networkList: IrisNetwork[] = <IrisNetwork[]>[];
    public scale = 1.0;

    constructor(private networkService: NetworkService, 
                private messageService: MessageService) {}
   
    ngOnInit(): void {}
   
    ngAfterViewInit(): void {
      this.listNetwork();
    }

    reset() {
      this.networkInstance.fit();
    }

    zoomIn() {
      this.scale = this.scale + 0.1
      this.networkInstance.moveTo({scale: this.scale})
    }

    zoomOut() {
      this.scale = this.scale - 0.1
      this.networkInstance.moveTo({scale: this.scale})
    }

    public listNetwork(): void {
      this.networkService.list().subscribe({
        next: response => {
            this.networkList = response;

            let nodeList = <Node[]>[];
            this.networkList.forEach(element => {
              let nodeItem = <Node>{};
              nodeItem.id = element.name;
              nodeItem.label = element.name;
              nodeItem.shape = 'box';
              nodeList.push(nodeItem);
            });
            const nodes = new DataSet<any>(nodeList);
            
            let edgeList = <Edge[]>[];
            this.networkList.forEach(element => {
              element.dependencies.forEach(depElement => {
                let edgeItem = <Edge>{};
                edgeItem.from = element.name;
                edgeItem.to = depElement.name;
                edgeList.push(edgeItem);  
              });
              
            });
            
            const edges = new DataSet<any>(edgeList);
            const data = { nodes, edges };
   
            const container = this.visNetwork;
            
            var options = {
              layout: {
                hierarchical: {
                  direction: "UD",
                  sortMethod: "directed",
                },
              },
              interaction: {
                navigationButtons: true,
                keyboard: true,
              },
              physics: {
                hierarchicalRepulsion: {
                  avoidOverlap: 1.0,
                },
              }
            };

            
            this.networkInstance = new Network(container.nativeElement, data, options);
            this.scale = this.networkInstance.getScale();

        },
        error: error => {
            console.log(error);
            this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Erro on load IRIS network.' });
        }
      });
    }
  }