export interface User {
  userId?: any | null;
  name?: string | null;
  bio?: any | null;
  email?: any | null;
  preferences?: any | null;
  tags?: any | null;
  moods?: any | null;
  createdAt?: any | null;
  updatedAt?: any | null;
  referrerId?: any | null;
}

export interface OrderHeader {
  orderId?: any | null;
  userRef?: any | null;
  shipAddress?: any | null;
  orderDate?: any | null;
}

export interface OrderItems {
  orderId?: any | null;
  userRef?: any | null;
  itemId?: any | null;
  quantity?: any | null;
  priceCents?: any | null;
}

