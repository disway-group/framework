import { LightningElement } from 'lwc';
export default class ErrorBoundary extends LightningElement {
  hasError=false;
  errorCallback(){ this.hasError=true; }
}
