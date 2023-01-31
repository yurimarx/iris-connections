import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { IrisNetwork } from './network';

@Injectable()
export class NetworkService {

  private url = environment.host + 'classes';

  constructor(private http: HttpClient) { }

  public list(): Observable<IrisNetwork[]> {
    return this.http.get<IrisNetwork[]>(this.url);
  }

}
