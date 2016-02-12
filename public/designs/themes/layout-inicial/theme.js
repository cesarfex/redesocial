jQuery(document).ready(function($) {
  // Run code

  $('.btn_control .logged-in #homepage-link').live('click', function(e){
   e.preventDefault();
   $("#wrap-0").toggleClass("menu");
	 $("#wrap-1").toggleClass("menu");
	 $("#theme-footer").toggleClass("menu");
  });

//abrir e fechar tarefas pendentes na barra do usuário//
  $(".btn_tasks").click(function(){
    $("#task_list").addClass("hide");
    $("#msg_list").addClass("hide");
    $("#task_list").toggleClass("hide");
  });

  $("#close_task").click(function(){
    $("#task_list").toggleClass("hide");
  });

//abrir e fechar mensagens não lidas na barra do usuário//
  $(".btn_msg").click(function(){
    $("#task_list").addClass("hide");
    $("#msg_list").addClass("hide");
    $("#msg_list").toggleClass("hide");
  });

  $("#close_msg").click(function(){
    $("#msg_list").toggleClass("hide");
  });

//abrir e fechar Painel de controle da comunidade//
  $("#btn_open_control_panel span").click(function(){
    $("#control_panel_bar").toggleClass("show");
    $("#btn_open_control_panel").toggleClass("show");
  });

//abrir e fechar Painel de controle da comunidade//
//aba conteúdo//
  $("#navigation ul li#btn_content").click(function(){
	 $("#control_panel_bar.menu_aparence").removeClass("show");
    $("#control_panel_bar.menu_settings").removeClass("show");
    $("#control_panel_bar.menu_content").toggleClass("show", 200);
  });
//aba aparência//
  $("#navigation ul li#btn_aparence").click(function(){
    $("#control_panel_bar.menu_settings").removeClass("show");
    $("#control_panel_bar.menu_content").removeClass("show");
    $("#control_panel_bar.menu_aparence").toggleClass("show", 200);
  });
//aba Configurações//
  $("#navigation ul li#btn_settings").click(function(){
    $("#control_panel_bar.menu_content").removeClass("show");
    $("#control_panel_bar.menu_aparence").removeClass("show");
    $("#control_panel_bar.menu_settings").toggleClass("show", 200);
  });

});
