import { NgModule } from '@angular/core';
import { RouterModule } from '@angular/router';
import { NetworkComponent } from './network.component';

@NgModule({
	imports: [RouterModule.forChild([
		{ path: '', component: NetworkComponent }
	])],
	exports: [RouterModule]
})
export class NetworkRoutingModule { }
