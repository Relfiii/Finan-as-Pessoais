-- Criação da tabela categorias_gastos
CREATE TABLE IF NOT EXISTS public.categorias_gastos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nome text NOT NULL
);

-- Criação da tabela de gastos
CREATE TABLE IF NOT EXISTS public.gastos (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  valor numeric NOT NULL,
  categoria_id uuid REFERENCES public.categorias_gastos(id),
  descricao text,
  data timestamp with time zone NOT NULL DEFAULT now(),
  user_id uuid REFERENCES auth.users(id)
);

-- Criar índice para user_id
CREATE INDEX IF NOT EXISTS idx_gastos_user_id ON public.gastos(user_id);

-- Habilitar RLS
ALTER TABLE public.gastos ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Gastos apenas do usuário" ON public.gastos
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Inserir gastos do próprio usuário" ON public.gastos
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Atualizar gastos do próprio usuário" ON public.gastos
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Deletar gastos do próprio usuário" ON public.gastos
  FOR DELETE USING (user_id = auth.uid());