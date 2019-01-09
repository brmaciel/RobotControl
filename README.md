Robot Control


Software para múltiplos modos de controle de um robô.
Desenvolvido para dispositivos iOS (iPads)


Componentes:
 - Microcontrolador Arduino
 - Motor Shield L298P
 - Módulo Bluetooth HM-10 BLE 4.0
 - (4x) Sensores de proximidade ultrassônico HC-SR04


Modos de Controle:
1. MANUAL
   Usuário controla livremente o robô

2. AUTOMÁTICO
   Robô se move automaticamente pelo espaço detectando e evitando obstáculos a partir

3. SEMIAUTOMÁTICO
   Também chamado de modo ANTICOLISÃO
   É uma combinação entre os 2 modos anteriores.
   Usuário controla o robô como no modo manual, porém robô faz uso dos sensores de proximidade para detectar obstáculos e evitar a colisão. Robô é capaz de ignorar o comando do usuário quando o comando direciona o robô a um obstáculo

4. TRAJETÓRIA
   Usuário define coordenadas no dispositivo móvel, e uma trajetória é traçada entre os pontos. Então o robô realiza a trajetória.
      (Ainda não implementado no microcontrolador, pois requisita sensores de posicionamento)