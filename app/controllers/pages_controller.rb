class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:cartola_suggestions, :update_players]

  def index
  end

  # Função para buscar os melhores jogadores baseado nas informações disponíveis no Banco de Dados
  def cartola_suggestions
    # Se a contagem de jogadores está em 0 (ou seja, a função update_players ainda não foi rodada uma vez), redirecionar para a página principal
    if Player.count == 0
      flash[:alert] = "O banco de dados não está atualizado. Retorne mais tarde."
      redirect_to(:action => 'index')
    else
      # Garante que o preço total do time não ultrapassará o orçamento inicial de 100 cartoletas
      max_price = 100.0 / 12.0

      # Seleciona os 10 melhores jogadores de cada posição, ordenando pelo campo de score_per_price (decrescente). Seleção (arbitrária)
      # de jogadores com score > 2
      @best_midfielders = Player.where("position = 'Meia' and score > 2 and price < #{max_price}").sort_by(&:score_per_price).reverse.first(10)
      @best_centre_backs = Player.where("position = 'Zagueiro' and score > 2 and price < #{max_price}").sort_by(&:score_per_price).reverse.first(10)
      @best_full_backs = Player.where("position = 'Lateral' and score > 2 and price < #{max_price}").sort_by(&:score_per_price).reverse.first(10)
      @best_goalkeepers = Player.where("position = 'Goleiro' and score > 2 and price < #{max_price}").sort_by(&:score_per_price).reverse.first(10)
      @best_attackers = Player.where("position = 'Atacante' and score > 2 and price < #{max_price}").sort_by(&:score_per_price).reverse.first(10)

      # Criar array para possível escalação
      @possible_lineup = []

      # Adicionar jogadores baseados no maior Score, conforme a quantidade requerida para cada posição
      @possible_lineup << @best_goalkeepers.sort_by(&:score).reverse.first

      @best_centre_backs.sort_by(&:score).reverse.first(2).each do |p|
        @possible_lineup << p
      end

      @best_full_backs.sort_by(&:score).reverse.first(2).each do |p|
        @possible_lineup << p
      end

      @best_midfielders.sort_by(&:score).reverse.first(4).each do |p|
        @possible_lineup << p
      end

      @best_attackers.sort_by(&:score).reverse.first(2).each do |p|
        @possible_lineup << p
      end

      # Para o técnico, selecionar o mais barato
      @possible_lineup << Player.where("position = 'Tecnico'").sort_by(&:price).first

      # Calcular soma do valor total da escalação
      @lineup_value = 0.0
      @possible_lineup.each do |p|
        @lineup_value += p.price
      end
    end
  end

  # Função para fazer a atualização das informações dos jogadores no Banco de Dados
  def update_players
    # Se o usuário é administrador
    if current_user.admin?
      # Chamada para a API do Cartola com informações dos jogadores e manipulação da resposta em JSON
      response = HTTParty.get('https://api.cartolafc.globo.com/atletas/mercado').body
      response_hash = JSON.parse(response)
      players = response_hash['atletas']

      # Para cada jogador, encontrar o jogador pelo campo atleta_id para fazer update ou criar novo registro
      players.each do |p|
        player = Player.find_or_create_by(player_id: p['atleta_id'])
        # Extrair todas as informações desejadas sobre jogadores do JSON
        player.nickname = p['apelido']
        player.player_id = p['atleta_id']
        if p['posicao_id'] == 1
          player.position = 'Goleiro'
        elsif p['posicao_id'] == 2
          player.position = 'Lateral'
        elsif p['posicao_id'] == 3
          player.position = 'Zagueiro'
        elsif p['posicao_id'] == 4
          player.position = 'Meia'
        elsif p['posicao_id'] == 5
          player.position = 'Atacante'
        elsif p['posicao_id'] == 6
          player.position = 'Tecnico'
        end
        player.price = p['preco_num']

        # Caso alguma das informações desejadas não esteja definida, definir como 0
        player.clean_sheets = p['scout']['SG'].presence || 0
        player.penalty_defenses = p['scout']['DP'].presence || 0
        player.good_saves = p['scout']['DD'].presence || 0
        player.ball_steals = p['scout']['RB'].presence || 0
        player.own_goals = p['scout']['GC'].presence || 0
        player.red_cards = p['scout']['CV'].presence || 0
        player.yellow_cards = p['scout']['CA'].presence || 0
        player.goals_against = p['scout']['GS'].presence || 0
        player.fouls_committed = p['scout']['FC'].presence || 0
        player.goals = p['scout']['G'].presence || 0
        player.assists = p['scout']['A'].presence || 0
        player.shots_on_the_bar = p['scout']['FT'].presence || 0
        player.shots_defended = p['scout']['FD'].presence || 0
        player.shots_off_target = p['scout']['FF'].presence || 0
        player.fouls_suffered = p['scout']['FS'].presence || 0
        player.penalties_lost = p['scout']['PP'].presence || 0
        player.offsides = p['scout']['I'].presence || 0
        player.missed_passes = p['scout']['PE'].presence || 0
        player.games = p['jogos_num'].presence || 0

        # Se o jogador não jogou, score = 0 e score_per_price = 0
        if player.games == 0
          player.score = 0.0
          player.score_per_price = 0.0
        else
          # Calcular Score baseado na pontuação do cartola. Para cada posição, diferentes estatísticas e pesos são utilizados
          # Dividir o resultado final pelo número de jogos para normalizar
          # Pesos retirados de: http://globoesporte.globo.com/cartola-fc/noticia/2015/07/entenda-pontuacoes-do-cartola-fc-e-defina-como-escalar-sua-equipe.html
          if player.position == "Goleiro"
            player.score = (((5.0 * player.clean_sheets) + (7.0 * player.penalty_defenses) + (3.0 * player.good_saves) +
                            (-6.0 * player.own_goals) + (1.7 * player.ball_steals) + (-5.0 * player.red_cards) +
                            (-2.0 * player.yellow_cards) + (-2.0 * player.goals_against) + (-0.5 * player.fouls_committed)) / player.games)
          elsif player.position == "Lateral" or player.position == "Zagueiro"
            player.score = (((5.0 * player.clean_sheets) + (-6.0 * player.own_goals) + (1.7 * player.ball_steals) +
                            (-5.0 * player.red_cards) + (-2.0 * player.yellow_cards) + (-0.5 * player.fouls_committed)) / player.games)
          elsif player.position == "Meia" or player.position == "Atacante"
            player.score = (((8.0 * player.goals) + (5.0 * player.assists) + (3.5 * player.shots_on_the_bar) +
                            (1.0 * player.shots_defended) + (0.7 * player.shots_off_target) + (0.5 * player.fouls_suffered) +
                            (-3.5 * player.penalties_lost) + (-0.5 * player.offsides) + (-0.3 * player.missed_passes)) / player.games)
          # Para o técnico não há informações de Scout. Para a escalação, será selecionado o mais barato.
          elsif player.position == "Tecnico"
            player.score = 0.0
            player.score_per_price = 0.0
          end
          player.score_per_price = player.score / player.price
        end
        # Salva o jogador
        player.save
      end
      # Redireciona para as sugestões
      redirect_to(:action => 'cartola_suggestions')
    else
      flash[:alert] = "Você não tem permissão para acessar esta página"
      redirect_to(:action => 'index')
    end
  end

end
