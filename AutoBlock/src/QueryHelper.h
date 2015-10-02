#ifndef QUERYHELPER_H_
#define QUERYHELPER_H_

#include <QStringList>
#include <QFileSystemWatcher>

#include "DatabaseHelper.h"
#include "QueryId.h"

namespace canadainc {
	class Persistance;
}

namespace bb {
    namespace pim {
        namespace message {
            class MessageService;
        }
    }
}

namespace autoblock {

using namespace canadainc;
using namespace bb::pim::message;

class QueryHelper : public QObject
{
	Q_OBJECT
	Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)

	DatabaseHelper m_sql;
	Persistance* m_persist;
    MessageService* m_ms;
    qint64 m_lastUpdate;
    QFileSystemWatcher m_updateWatcher;
    bool m_logSearchMode;
    QMap<qint64, quint64> m_accountToTrash;

    void prepareTransaction(QString const& query, QVariantList const& elements, QueryId::Type qid, QueryId::Type chunkId);

private slots:
    void databaseUpdated(QString const& path);
    void onDataLoaded(QVariant id, QVariant data);

Q_SIGNALS:
    void dataReady(int id, QVariant const& data);
    void readyChanged();

public:
	QueryHelper(Persistance* persist);
	virtual ~QueryHelper();

    Q_INVOKABLE void clearBlockedKeywords();
    Q_INVOKABLE void clearBlockedSenders();
    Q_INVOKABLE void cleanInvalidEntries();
    Q_INVOKABLE void clearLogs();
    Q_INVOKABLE void fetchAllBlockedKeywords(QString const& filter=QString());
    Q_INVOKABLE void fetchAllBlockedSenders(QString const& filter=QString());
    Q_INVOKABLE void fetchAllLogs(QString const& filter=QString());
    Q_INVOKABLE void fetchExcludedWords(QString const& filter=QString());
    Q_INVOKABLE void fetchLatestLogs();
    Q_INVOKABLE QStringList block(QVariantList const& numbers);
    Q_INVOKABLE QStringList blockKeywords(QVariantList const& keywords);
    Q_INVOKABLE QStringList unblock(QVariantList const& senders);
    Q_INVOKABLE QStringList unblockKeywords(QVariantList const& keywords);
    Q_INVOKABLE void optimize();
    Q_SLOT bool checkDatabase(QString const& path=QString());
    bool ready() const;
    Q_INVOKABLE void setActive(bool active);

    void attachReportedDatabase(QString const& tempDatabase);
    Persistance* getPersist();

    void lazyInit();
};

} /* namespace autoblock */
#endif /* QUERYHELPER_H_ */
