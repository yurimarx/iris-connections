import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';

@Injectable()
export class MindmapService {

  private url = environment.host + 'inventory';

  constructor(private http: HttpClient) { }

  public getClassInventoryInMarkdown(): Observable<string> {
    const headers = new HttpHeaders().set('Content-Type', 'text/plain; charset=utf-8');
    return this.http.get(this.url, { headers, responseType: 'text'});
  }

}
