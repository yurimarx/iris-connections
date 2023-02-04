import { Component, OnInit } from '@angular/core';
import { MessageService } from 'primeng/api';
import { MindmapService } from './mindmap.service';
import * as markmap from "markmap-view";
import { Transformer } from "markmap-lib";
import { ViewChild } from '@angular/core';
import { ElementRef } from '@angular/core';

@Component({
    templateUrl: './mindmap.component.html',
    styleUrls: ['./mindmap.css'],
    providers: [MessageService, MindmapService]
})
export class MindmapComponent implements OnInit {

    @ViewChild('svg', { static: true })
    public _svg: ElementRef<SVGElement> = {} as ElementRef;
    public content: string = "## IRIS Connections";
    constructor(private mindmapService: MindmapService,
        private messageService: MessageService) { }

    ngOnInit(): void {

        this.mindmapService.getClassInventoryInMarkdown().subscribe({
            next: response => {
                this.content = response
                const transformer = new Transformer();
                const { root } = transformer.transform(this.content);
                const { styles, scripts } = transformer.getAssets();
                const { Markmap, loadCSS, loadJS } = markmap;

                if (styles) loadCSS(styles);
                if (scripts) loadJS(scripts, { getMarkmap: () => markmap });

                Markmap.create(this._svg.nativeElement, undefined, root);

            },
            error: error => {
                console.log(error);
                this.messageService.add({ severity: 'error', summary: 'Error', detail: 'Error on load IRIS classes inventory.' });
            }
        });
    }


}