# Geneswork LLC

Static site for [genesworkllc.com](https://genesworkllc.com). Netlify publishes this repository as-is.

The estimate form is named `estimate` and uses Netlify Forms (`data-netlify="true"`). Submissions land in the Netlify Forms tab. Netlify does not email them until a notification is turned on. After the first production deploy, open **Site configuration → Forms → Form notifications** and send notifications to genesworkllc@gmail.com.

## Local preview

```bash
python3 -m http.server 8765
```

Form delivery only works on Netlify, not on the local server. `bash scripts/verify_site.sh` checks the required business facts, form markup, and asset paths.
