export interface Users {
  id: number;
  username: string;
}

export interface Keywords {
  id: number;
  keyword: string;
  active: boolean;
}

export interface UserMessages {
  id: number;
  userId?: any | null;
  keywordId?: any | null;
  count?: any | null;
  lastMessage?: string | null;
  updatedAt?: string | null;
}

