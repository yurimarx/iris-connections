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
    providers: [MessageService, NetworkService]
})
export class NetworkComponent implements OnInit, AfterViewInit {
    @ViewChild('visNetwork', { static: false }) visNetwork!: ElementRef;
    public networkInstance: any;
    public networkList: IrisNetwork[] = <IrisNetwork[]>[];

    constructor(private networkService: NetworkService, 
                private messageService: MessageService) {}
   
    ngOnInit(): void {}
   
    ngAfterViewInit(): void {
      this.listNetwork();
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
            this.networkInstance = new Network(container.nativeElement, data, {});

        },
        error: error => {
            console.log(error);
            this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Erro on load IRIS network.' });
        }
      });
    }
  }