ALTER TABLE public.categorias
ADD COLUMN IF NOT EXISTS data timestamp with time zone DEFAULT now();
ADD COLUMN IF NOT EXISTS user_id uuid REFERENCES auth.users(id);

CREATE INDEX IF NOT EXISTS idx_categorias_user_id ON public.categorias(user_id);

ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Categorias apenas do usuário" ON public.categorias
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Inserir categorias do próprio usuário" ON public.categorias
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Atualizar categorias do próprio usuário" ON public.categorias
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Deletar categorias do próprio usuário" ON public.categorias
  FOR DELETE USING (user_id = auth.uid());