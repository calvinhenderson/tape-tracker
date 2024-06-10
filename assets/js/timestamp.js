const mktime = (utc_string) => {
  const locale = window.navigator.userLanguage || window.navigator.language;
  let date = new Date(utc_string);

  return date.toLocaleString(locale, {
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric'
  });
};

export default {
  mounted() { this.setContent(); },
  updated() { this.setContent(); },
  setContent() {
    time = this.el.getAttribute("data-timestamp");
    if (time == null)
      this.el.innerText = "Never";
    else
      this.el.innerText = mktime(time);
  }
};
