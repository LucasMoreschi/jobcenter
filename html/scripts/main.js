const chosen_language = 'en';

let current_image_folder = '';
let images = [];
let image_index = 0;
let translations = {}; 
let player_data = {};
let jobs_data = {};
let current_location = null;

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === 'open_jobcenter') {
        console.log(data.location_key)
        init_job_center(data.location_key, data.player, data.jobs, translations);
    } 
});

function load_language(lang, callback) {
    $.getJSON(`/html/scripts/language/${lang}.json`, function(data) {
        callback(data);
    });
}

load_language(chosen_language, function(data) {
    $(document).ready(function() {
        translations = data;
        //init_job_center('alta', player_data, jobs_data, translations);
    });
});

// Function to init job center ui
function init_job_center(location, player, jobs) {
    player_data = player;
    jobs_data = jobs;
    current_location = location
    $('#main_container').removeClass('hidden');
    generate_main_header(translations);
    generate_player_details(player, translations);
    generate_header_icons(translations);
    const sorted_jobs = generate_job_list(translations);
    generate_job_buttons(translations);
    generate_job_reputation(sorted_jobs[0]);
    bind_job_clicks(translations);
    populate_job_details(jobs[sorted_jobs[0]].ui, sorted_jobs[0], translations);
    $('.toggle_theme').click(toggle_dark_mode);
    $('.jobcenter_close_btn').click(function() {close_ui()});
    $('.jobcenter_header h3').text(translations.general.available_jobs);
    $('.jobdata_info_header h4').text(translations.general.job_info);
    $('.jobdata_prog_header h4').text(translations.general.job_rep);
    $(document).on('keydown', close_ui_keypress);
}

// Function to close ui on key press
function close_ui_keypress(e) {
    if (e.keyCode == 27) {
        close_ui();
    }
}

// Function to generate the main header
function generate_main_header(translations) {
    $('.jobcenter_header h3').text(translations.general.available_jobs);
}
function generate_player_details(player, translations) {
    const player_details_div = $('.jobcenter_player_details');
    player_details_div.empty();
    player_details_div.append(`<p><strong>${translations.general.welcome}</strong> ${player.name}</p>`);
}

// Function to generate header icons
function generate_header_icons() {
    const icons_div = $('.jobcenter_header_icons');
    icons_div.empty();
    icons_div.append($('<i>', { class: 'fas fa-sun toggle_theme' }));
    icons_div.append($('<i>', { class: 'fas fa-times jobcenter_close_btn' }));
}

// Function to generate the job list
function generate_job_list() {
    const job_list_div = $('.jobcenter_joblist');
    job_list_div.empty();
    const sorted_jobs = Object.keys(jobs_data).sort((a, b) => {
        return jobs_data[a].ui.title.localeCompare(jobs_data[b].ui.title);
    });
    sorted_jobs.forEach(job_name => {
        const job = jobs_data[job_name].ui;
        const job_div = $('<div>', { class: 'jobcenter_job', 'data-jobkey': job_name })
            .append($('<i>', { class: '' + job.icon + ' jobcenter_job_icon' }))
            .append($('<span>').text(job.title));
        job_list_div.append(job_div);
    });
    return sorted_jobs;
}

// Function to generate job buttons
function generate_job_buttons(translations) {
    const buttons_div = $('.jobdata_buttons');
    buttons_div.empty();
    buttons_div.append($('<button>', { id: 'accept_job_btn' }).text(translations.general.accept_job));
    buttons_div.append($('<button>', { id: 'job_locate_btn' }).text(translations.general.set_gps));
    buttons_div.append($('<button>', { id: 'job_guide_btn' }).text(translations.general.job_guide));
}

// Function to generate default rep for jobs
function generate_default_rep(job_name) {
    if (jobs_data[job_name] && jobs_data[job_name].reputation) {
        return {
            level: jobs_data[job_name].reputation.level,
            rep: jobs_data[job_name].reputation.current_rep || 0,
            first_level_rep: jobs_data[job_name].reputation.first_level_xp || jobs_data[job_name].reputation.first_level_rep,
            growth_factor: jobs_data[job_name].reputation.growth_factor,
            max_level: jobs_data[job_name].reputation.max_level
        };
    } else {
        return null;
    }
}

// Function to generate job rep for players jobs
function generate_job_reputation(job_name) {
    let reputation_data;
    if (player_data.reputation && player_data.reputation[job_name]) {
        reputation_data = player_data.reputation[job_name];
    } else {
        reputation_data = generate_default_rep(job_name);
    }
    let total_rep = reputation_data.first_level_rep;
    for (let i = 1; i < reputation_data.level; i++) {
        total_rep *= reputation_data.growth_factor;
    }
    total_rep = Math.round(total_rep);
    const progress_percentage = (reputation_data.current_rep / total_rep) * 100;
    $('.jobdata_current_rep').text(`${translations.reputation.level} ${reputation_data.level || 0} - ${reputation_data.current_rep || 0}/${total_rep}`);
    $("#job_rep_progress").progressbar({
        value: progress_percentage,
        max: 100
    });
}

// Function to update background image
function update_background_image() {
    let next_image = $('.next_image');
    let current_image = $('.current_image');
    next_image.css('backgroundImage', `url(/html/assets/images/${current_image_folder}/${images[image_index]})`);
    current_image.removeClass('current_image').addClass('next_image');
    next_image.removeClass('next_image').addClass('current_image');
    image_index = (image_index + 1) % images.length;
}
setInterval(update_background_image, 6000);

// Function to bind on clicks to job elements
function bind_job_clicks() {    
    $('.jobcenter_job').click(function() {
        const job_name = $(this).data('jobkey');
        populate_job_details(jobs_data[job_name].ui, job_name);
    });
    $('#job_guide_btn').click(function() {
    const job_name = $('.jobdata_header h3').data('jobkey');
        if (jobs_data[job_name] && jobs_data[job_name].ui.guide) {
            display_job_guide(jobs_data[job_name].ui.guide);
        } else {
            console.error("Guide not found for:", job_name);
        }
    });
    $('#accept_job_btn').click(function() {
        const job_name = $('.jobdata_header h3').data('jobkey');
        console.log("Job Name:", job_name);

        const job_details = jobs_data[job_name];
        if (job_details) {
            const post_data = {
                location: current_location,
                job: job_details
            };
            $.post('https://boii_jobcenter/accept_job', JSON.stringify(post_data));
        } else {
            console.error("Job details not found for job key:", job_name);
        }
    });
    
    $('#job_locate_btn').click(function() {
        const job_name = $('.jobdata_header h3').data('jobkey');
        const job_details = jobs_data[job_name];
        if (job_details && job_details.job.location) {
            $.post('https://boii_jobcenter/locate_job', JSON.stringify(job_details.job.location));
        }
    });
}

// Function to populat job details
function populate_job_details(job_details, job_name) {
    const header = $('.jobdata_header h3');
    header.text(job_details.title);
    header.data('jobkey', job_name);
    const job_details_content = $('.jobdata_info_content');
    job_details_content.empty();
    job_details_content.append(`<p><strong>${translations.job_details.salary}</strong> ${job_details.salary}</p>`);
    job_details_content.append(`<p><strong>${translations.job_details.role}</strong> ${job_details.role}</p>`);
    job_details_content.append(`<p><strong>${translations.job_details.description}</strong> ${job_details.description}</p>`);
    if (!job_details.images || job_details.images.length === 0) {
        current_image_folder = 'default';
        images = ['no_image.jpg'];
    } else {
        current_image_folder = job_details.images_folder;
        images = job_details.images;
    }
    image_index = 0;
    generate_job_reputation(job_name);
    update_background_image();
}

// Function to display job guide content
function display_job_guide(guide) {
    const guide_container = $('.jobdata_guide_container');
    const content = `
        <h3>${guide.title}</h3>
        <div class="guide_content">
            <p>${guide.content}</p>
        </div>    
        <button class="jobdata_close_guide"><i class="fas fa-times jobcenter_close_btn"></i></button>
    `;
    guide_container.empty().append(content);
    $('.jobdata_close_guide').click(function () {
        guide_container.hide();
        reload_image_container();
    });
    $('.jobdata_image_container').hide();
    guide_container.show();
}

// Function to reload the image container
function reload_image_container() {
    $('.jobdata_image_container').show();
    // Add code here to update the image in the image container if needed
}

// Function to set players saved theme
function set_player_theme() {
    const pref_theme = localStorage.getItem('jobcenter_theme');
    const container = $('.jobcenter_container, .jobcenter_jobdata, .jobcenter_joblist, .jobdata_current_rep');
    const theme_toggle = $('.toggle_theme');
    if (pref_theme === 'light') {
        container.removeClass('darkmode');
        theme_toggle.removeClass('fa-sun').addClass('fa-moon');
        theme_toggle.attr('title', 'Dark Mode');
    } else {
        container.addClass('darkmode');
        theme_toggle.removeClass('fa-moon').addClass('fa-sun');
        theme_toggle.attr('title', 'Light Mode');
    }
}
set_player_theme();

// Function to toggle dark mode
function toggle_dark_mode() {
    const container = $('.jobcenter_container, .jobcenter_jobdata, .jobcenter_joblist, .jobdata_buttons, .jobdata_current_rep');
    const theme_toggle = $('.toggle_theme');
    const is_dark_mode = container.hasClass('darkmode');
    if (is_dark_mode) {
        container.removeClass('darkmode');
        theme_toggle.removeClass('fa-sun').addClass('fa-moon');
        localStorage.setItem('jobcenter_theme', 'light');
    } else {
        container.addClass('darkmode');
        theme_toggle.removeClass('fa-moon').addClass('fa-sun');
        localStorage.setItem('jobcenter_theme', 'dark');
    }
}

// Function to close ui
function close_ui() {
    $('#main_container').addClass('hidden');
    $.post('https://boii_jobcenter/close_ui', JSON.stringify({}));
}