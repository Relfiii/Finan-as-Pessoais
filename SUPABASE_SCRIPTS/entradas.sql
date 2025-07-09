-- Criação da tabela de entradas
CREATE TABLE IF NOT EXISTS entradas (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  descricao text NOT NULL,
  valor numeric NOT NULL,
  data date NOT NULL,
  created_at timestamp with time zone DEFAULT timezone('utc', now()),
  user_id uuid REFERENCES auth.users(id)
);

-- Criar índice para user_id
CREATE INDEX IF NOT EXISTS idx_entradas_user_id ON entradas(user_id);

-- Habilitar RLS
ALTER TABLE entradas ENABLE ROW LEVEL SECURITY;

-- Políticas de segurança
CREATE POLICY "Entradas apenas do usuário" ON entradas
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Inserir entradas do próprio usuário" ON entradas
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Atualizar entradas do próprio usuário" ON entradas
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Deletar entradas do próprio usuário" ON entradas
  FOR DELETE USING (user_id = auth.uid());