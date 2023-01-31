export interface IrisNetwork {
  name: string
  super: string
  persistent: string
  serial: string
  sqltablename: string
  content: string
  description: string
  dependencies: Dependency[]
  properties: Property[]
  methods: Method[]
}

export interface Dependency {
  name: string
}

export interface Property {
  name: string
  type: string
}

export interface Method {
  name: string
  type: string
}
