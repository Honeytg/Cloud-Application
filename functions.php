function my_theme_enqueue_styles(){
    wp_enqueque_style('theme-style', get_stylesheet_uri());
}
add_action('wp_enqueue_scripts','my_theme_enqueue_styles');