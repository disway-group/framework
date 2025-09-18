import { LightningElement, api } from 'lwc';
export default class EmptyState extends LightningElement {
  @api iconName='utility:info';
  @api title='Sem dados';
  @api description='';
}
