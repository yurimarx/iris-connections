import { NgModule } from '@angular/core';
import { HashLocationStrategy, LocationStrategy } from '@angular/common';
import { AppComponent } from './app.component';
import { AppRoutingModule } from './app-routing.module';
import { AppLayoutModule } from './layout/app.layout.module';
import { NotfoundComponent } from './notfound/notfound.component';
import { HttpClientModule, HTTP_INTERCEPTORS } from '@angular/common/http';
import { BasicAuthInterceptor } from './security';
import { BrowserModule } from '@angular/platform-browser';
import { NuMarkdownModule } from '@ng-util/markdown';
import { FormsModule } from '@angular/forms';

@NgModule({
    declarations: [
        AppComponent, NotfoundComponent
    ],
    imports: [
        FormsModule,
        NuMarkdownModule.forRoot(),
        AppRoutingModule,
        AppLayoutModule,
        BrowserModule,
        HttpClientModule
    ],
    providers: [
        { provide: LocationStrategy, useClass: HashLocationStrategy },
        { provide: HTTP_INTERCEPTORS, useClass: BasicAuthInterceptor, multi: true },
    ],
    bootstrap: [AppComponent]
})
export class AppModule { }
