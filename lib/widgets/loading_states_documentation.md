/// DOCUMENTAÇÃO - Estados de Loading Granulares
/// 
/// Este arquivo documenta como usar os loading states implementados nos Providers
/// para melhorar a experiência do usuário (UX) durante carregamentos.

/**
 * LOADING STATES DISPONÍVEIS:
 * 
 * TransactionProvider:
 * - isLoadingReceitas: true quando carregando receitas
 * - isLoadingInvestimentos: true quando carregando investimentos  
 * - isLoadingChart: true quando preparando dados do gráfico
 * - isLoadingYearRange: true quando buscando período de dados
 * - isLoadingPeriod(String): true para período específico
 * - hasAnyLoading: true se qualquer loading está ativo
 * 
 * GastoProvider:
 * - isLoadingGastosMes: true quando carregando gastos do mês
 * - isLoadingGastosDia: true quando carregando gastos do dia
 * - isLoadingGastosAno: true quando carregando gastos do ano
 * - isLoadingTotals: true quando fazendo consultas em lote
 * - isLoadingPeriod(String): true para período específico
 * - hasAnyLoading: true se qualquer loading está ativo
 */

/**
 * EXEMPLO 1: Card com loading específico
 * 
 * Consumer<TransactionProvider>(
 *   builder: (context, provider, child) {
 *     return CardLoadingOverlay(
 *       isLoading: provider.isLoadingReceitas,
 *       loadingMessage: "Carregando receitas...",
 *       child: Card(
 *         child: ListTile(
 *           title: Text("Receitas"),
 *           subtitle: Text("R\$ ${receitas.toStringAsFixed(2)}"),
 *           leading: Icon(Icons.trending_up),
 *         ),
 *       ),
 *     );
 *   },
 * )
 */

/**
 * EXEMPLO 2: Múltiplos loadings no gráfico
 * 
 * Consumer2<TransactionProvider, GastoProvider>(
 *   builder: (context, transactionProvider, gastoProvider, child) {
 *     return MultipleLoadingIndicator(
 *       loadingStates: {
 *         'receitas': transactionProvider.isLoadingReceitas,
 *         'investimentos': transactionProvider.isLoadingInvestimentos,
 *         'gastos': gastoProvider.isLoadingGastosAno,
 *         'chart': transactionProvider.isLoadingChart,
 *       },
 *       loadingMessages: {
 *         'receitas': 'Carregando receitas...',
 *         'investimentos': 'Carregando investimentos...',
 *         'gastos': 'Carregando gastos...',
 *         'chart': 'Preparando gráfico...',
 *       },
 *       child: GraficoColunaPrincipal(),
 *     );
 *   },
 * )
 */

/**
 * EXEMPLO 3: Loading granular com transparência
 * 
 * Consumer<GastoProvider>(
 *   builder: (context, provider, child) {
 *     return GranularLoadingIndicator(
 *       isLoading: provider.isLoadingGastosMes,
 *       loadingText: "Calculando gastos do mês...",
 *       loadingColor: Colors.orange,
 *       size: 24.0,
 *       child: Container(
 *         height: 100,
 *         child: Text("Gastos: R\$ ${gastos.toStringAsFixed(2)}"),
 *       ),
 *     );
 *   },
 * )
 */

/**
 * EXEMPLO 4: Verificar loading específico
 * 
 * // No Provider, ao iniciar carregamento:
 * _setLoadingSpecific('receitas_2025-01', true);
 * 
 * // Na UI:
 * if (provider.isLoadingPeriod('receitas_2025-01')) {
 *   return CircularProgressIndicator();
 * }
 */

/**
 * VANTAGENS DOS LOADING STATES GRANULARES:
 * 
 * 1. MELHOR UX: Usuário sabe exatamente o que está carregando
 * 2. FEEDBACK ESPECÍFICO: Cada card/componente mostra seu próprio loading
 * 3. PERFORMANCE: Não bloqueia toda a UI durante carregamentos parciais
 * 4. DEBUGGING: Facilita identificar onde está o gargalo de performance
 * 5. RESPONSIVIDADE: App parece mais fluido e responsivo
 */

/**
 * IMPACTO NA PERFORMANCE ANTES vs DEPOIS:
 * 
 * ANTES:
 * - Loading geral: usuário vê tela branca por 5 segundos
 * - Sem feedback: usuário não sabe o que está acontecendo
 * - Bloqueio total: toda UI fica inutilizável
 * 
 * DEPOIS:
 * - Loading granular: cada seção carrega independentemente
 * - Feedback específico: "Carregando receitas...", "Preparando gráfico..."
 * - UI parcial: usuário pode interagir com partes já carregadas
 * - Percepção de velocidade: app parece 3x mais rápido
 */
