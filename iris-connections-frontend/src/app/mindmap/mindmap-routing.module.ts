import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { MindmapComponent } from './mindmap.component';

@NgModule({
	imports: [RouterModule.forChild([
		{ path: '', component: MindmapComponent }
	])],
	exports: [RouterModule]
})
export class MindmapRoutingModule { }
