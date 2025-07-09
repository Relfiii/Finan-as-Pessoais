-- Criação da tabela de investimentos
CREATE TABLE IF NOT EXISTS investimentos (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  descricao text NOT NULL,
  valor numeric NOT NULL,
  data date NOT NULL,
  tipo text NOT NULL DEFAULT 'Outro',
  tipo_outro text,
  created_at timestamp with time zone DEFAULT timezone('utc', now()),
  user_id uuid REFERENCES auth.users(id)
);

-- Criar índice para user_id
CREATE INDEX IF NOT EXISTS idx_investimentos_user_id ON investimentos(user_id);

-- Habilitar RLS
ALTER TABLE investimentos ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'investimentos' AND policyname = 'Investimentos apenas do usuário'
  ) THEN
    CREATE POLICY "Investimentos apenas do usuário" ON investimentos
      FOR SELECT USING (user_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'investimentos' AND policyname = 'Inserir investimentos do próprio usuário'
  ) THEN
    CREATE POLICY "Inserir investimentos do próprio usuário" ON investimentos
      FOR INSERT WITH CHECK (user_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'investimentos' AND policyname = 'Atualizar investimentos do próprio usuário'
  ) THEN
    CREATE POLICY "Atualizar investimentos do próprio usuário" ON investimentos
      FOR UPDATE USING (user_id = auth.uid());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname = 'public' AND tablename = 'investimentos' AND policyname = 'Deletar investimentos do próprio usuário'
  ) THEN
    CREATE POLICY "Deletar investimentos do próprio usuário" ON investimentos
      FOR DELETE USING (user_id = auth.uid());
  END IF;
END $$;