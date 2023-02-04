import { NgModule } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MindmapRoutingModule } from './mindmap-routing.module';
import { MindmapComponent } from './mindmap.component';
import { TableModule } from 'primeng/table';
import { FileUploadModule } from 'primeng/fileupload';
import { ButtonModule } from 'primeng/button';
import { RippleModule } from 'primeng/ripple';
import { ToastModule } from 'primeng/toast';
import { ToolbarModule } from 'primeng/toolbar';
import { RatingModule } from 'primeng/rating';
import { InputTextModule } from 'primeng/inputtext';
import { InputTextareaModule } from 'primeng/inputtextarea';
import { DropdownModule } from 'primeng/dropdown';
import { RadioButtonModule } from 'primeng/radiobutton';
import { InputNumberModule } from 'primeng/inputnumber';
import { DialogModule } from 'primeng/dialog';
import { NuMarkdownModule } from '@ng-util/markdown';
import { TabViewModule } from 'primeng/tabview';
import {CardModule} from 'primeng/card';
import {AccordionModule} from 'primeng/accordion';
import {ScrollPanelModule} from 'primeng/scrollpanel';

@NgModule({
    imports: [
        CommonModule,
        AccordionModule,
        MindmapRoutingModule,
        NuMarkdownModule.forRoot(),
        ScrollPanelModule,
        CardModule,
        FileUploadModule,
        TabViewModule,
        ButtonModule,
        RippleModule,
        ToastModule,
        ToolbarModule,
        RatingModule,
        InputTextModule,
        InputTextareaModule,
        DropdownModule,
        RadioButtonModule,
        InputNumberModule,
        DialogModule
    ],
    declarations: [MindmapComponent]
})
export class MindmapModule { }
