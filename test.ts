export interface Posts {
  id: string;
  authorId: string;
  title: string;
  body: string;
  published: boolean;
  createdAt: string;
}

export interface Users {
  userId: string;
  name: string;
  bio?: string | null;
  email?: string | null;
  preferences?: any | null;
  tags?: string[] | null;
  moods: any[];
  createdAt: string;
  updatedAt: string;
  referrerId?: string | null;
}

export interface OrderHeader {
  orderId?: number | null;
  userRef: string;
  shipAddress: any;
  orderDate: string;
}

export interface OrderItems {
  orderId: any;
  userRef: string;
  itemId: any;
  quantity: any;
  priceCents: any;
}

